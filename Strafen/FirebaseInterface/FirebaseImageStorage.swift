//
//  FirebaseImageStorage.swift
//  Strafen
//
//  Created by Steven on 27.05.21.
//

import FirebaseStorage

/// Used to storage and fetch images from server
@MainActor class FirebaseImageStorage {

    /// Shared instance for singelton
    static let shared = FirebaseImageStorage()

    /// Private init for singleton
    private init() {}

    /// Image type
    enum ImageType {

        /// Club image
        case clubImage(clubId: Club.ID)

        /// Person image
        case personImage(clubId: Club.ID, personId: FirebasePerson.ID)

        /// Url to image
        var url: URL {
            switch self {
            case .clubImage(clubId: let clubId):
                return URL(string: "images")!
                    .appendingPathComponent(clubId.uuidString.uppercased())
                    .appendingPathComponent("original")
            case .personImage(clubId: let clubId, personId: let personId):
                return URL(string: "images")!
                    .appendingPathComponent(clubId.uuidString.uppercased())
                    .appendingPathComponent(personId.uuidString.uppercased())
                    .appendingPathComponent("original")
            }
        }

        /// Url to image with image size
        func url(with imageSize: ImageSize) -> URL {
            switch self {
            case .clubImage(clubId: let clubId):
                return URL(string: "images")!
                    .appendingPathComponent(clubId.uuidString.uppercased())
                    .appendingPathComponent(imageSize.imageName)
            case .personImage(clubId: let clubId, personId: let personId):
                return URL(string: "images")!
                    .appendingPathComponent(clubId.uuidString.uppercased())
                    .appendingPathComponent(personId.uuidString.uppercased())
                    .appendingPathComponent(imageSize.imageName)
            }
        }
    }

    /// Size of downloaded image
    enum ImageSize: Int, CaseIterable, Comparable {

        /// Small thumbnail
        case thumbsSmall = 0

        /// Standard thumbnail
        case thumbStandard = 1

        /// Big thumbnail
        case thumbBig = 2

        /// Original size
        case original = 3

        /// Image name
        var imageName: String {
            switch self {
            case .thumbsSmall:
                return "thumb@64"
            case .thumbStandard:
                return "thumb@128"
            case .thumbBig:
                return "thumb@256"
            case .original:
                return "original"
            }
        }

        static func < (lhs: ImageSize, rhs: ImageSize) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    /// Storage bucket url
    static let storageBucketUrl: String = "gs://strafen-app.appspot.com"

    /// Compression quality
    static let compressionQuality: CGFloat = 0.85

    /// Error appears while storing an image
    enum StoreError: Error {

        /// Couldn't get data from image
        case noImageData

        /// Internal error on image storage
        case onStore

        /// Internal error on image fetching
        case onFetch
    }

    /// Cache of small / standard / big and original images
    struct ImageCache {

        /// Small images
        var smallImages: DataCache<UUID, UIImage>

        /// Standard images
        var standardImages: DataCache<UUID, UIImage>

        /// Big images
        var bigImages: DataCache<UUID, UIImage>

        /// Original images
        var originalImages: DataCache<UUID, UIImage>

        init(maxSmall: Int, maxStandard: Int, maxBig: Int, maxOriginal: Int) {
            smallImages = DataCache(maxItems: maxSmall)
            standardImages = DataCache(maxItems: maxStandard)
            bigImages = DataCache(maxItems: maxBig)
            originalImages = DataCache(maxItems: maxOriginal)
        }

        /// Clear all caches
        mutating func clearAll() {
            smallImages.clear()
            standardImages.clear()
            bigImages.clear()
            originalImages.clear()
        }

        /// Append image to all caches
        /// - Parameters:
        ///   - image: image to append to all caches
        ///   - key: key of the image to append
        mutating func appendToAll(_ image: UIImage, with key: UUID) {
            smallImages[key] = image
            standardImages[key] = image
            bigImages[key] = image
            originalImages[key] = image
        }

        /// Append image to all caches smaller or equal size than given image size
        /// - Parameters:
        ///   - imageSize: image size
        ///   - image: image to append to caches
        ///   - key: key of the image to append
        mutating func appendToAllSmaller(than imageSize: ImageSize, _ image: UIImage, with key: UUID) {
            if imageSize >= .original { originalImages[key] = image }
            if imageSize >= .thumbBig { bigImages[key] = image }
            if imageSize >= .thumbStandard { standardImages[key] = image }
            if imageSize >= .thumbsSmall { smallImages[key] = image }
        }

        /// Delete image with given key from all caches
        /// - Parameter key: key of image to delete from caches
        mutating func deleteFromAll(with key: UUID) {
            smallImages[key] = nil
            standardImages[key] = nil
            bigImages[key] = nil
            originalImages[key] = nil
        }

        /// Get image with given key and size
        ///
        /// If image with given size doen't exist in cache, but the image with greater size,
        /// this image is returned
        /// - Parameters:
        ///   - key: key of image to get
        ///   - imageSize: size of image to get
        /// - Returns: image from cache or nil if there are no image with given key in cache
        func getImage(with key: UUID, imageSize: ImageSize) -> UIImage? {
            if imageSize <= .original, let image = originalImages[key] { return image}
            if imageSize <= .thumbBig, let image = bigImages[key] { return image }
            if imageSize <= .thumbStandard, let image = standardImages[key] { return image }
            if imageSize <= .thumbsSmall, let image = smallImages[key] { return image }
            return nil
        }
    }

    /// Person image cache
    var personImageCache = ImageCache(maxSmall: 40, maxStandard: 20, maxBig: 10, maxOriginal: 1)

    /// Club image cache
    var clubImageCache = ImageCache(maxSmall: 1, maxStandard: 1, maxBig: 1, maxOriginal: 1)

    /// Stores image on server
    /// - Parameters:
    ///   - image: image to store on server
    ///   - imageType: type of image to store
    ///   - progressChangeHandler: handles store progress changes
    /// - Returns: metadata of stored image
    @discardableResult func store(_ image: UIImage, of imageType: ImageType, progress progressChangeHandler: ((Double) -> Void)? = nil) async throws -> StorageMetadata {
        guard let imageData = image.jpegData(compressionQuality: Self.compressionQuality) else { throw StoreError.noImageData }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var storageResult: Result<StorageMetadata, Error>?

        // Store image
        let uploadTask = Storage.storage(url: Self.storageBucketUrl).reference(withPath: imageType.url.path).putData(imageData, metadata: metadata) { [weak self] metadata, error in
            if let metadata = metadata {
                storageResult = .success(metadata)
                dispatchGroup.leave()
                switch imageType {
                case .clubImage(clubId: let key):
                    self?.clubImageCache.appendToAll(image, with: key.rawValue)
                case .personImage(clubId: _, personId: let key):
                    self?.personImageCache.appendToAll(image, with: key.rawValue)
                }
            } else if let error = error {
                 storageResult = .failure(error)
                dispatchGroup.leave()
            } else {
                storageResult = .failure(StoreError.onStore)
                dispatchGroup.leave()
            }
        }

        // Observe progress change
        if let progressChangeHandler = progressChangeHandler {
            uploadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                progressChangeHandler(progress)
            }
        }

        // Return metadata
        return try await withCheckedThrowingContinuation { continuation in
            dispatchGroup.notify(queue: .main) {
                progressChangeHandler?(1.0)
                guard let metadataResult = storageResult else {
                    return continuation.resume(throwing: StoreError.onStore)
                }
                continuation.resume(with: metadataResult)
            }
        }
    }

    /// Fetch image from server
    /// - Parameters:
    ///   - imageType: type of image to fetch
    ///   - imageSize: size of image to fetch
    ///   - progressChangeHandler: handles fetch progress changes
    /// - Returns: fetched image
    private func fetch(_ imageType: ImageType, size imageSize: ImageSize, progress progressChangeHandler: ((Double) -> Void)? = nil) async throws -> UIImage {
        let maxSize: Int64 = 30 * 1024 * 1024 // 30 MB
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var fetchResult: Result<UIImage, Error>?

        // Fetch image
        let downloadTask = Storage.storage(url: Self.storageBucketUrl).reference(withPath: imageType.url(with: imageSize).path).getData(maxSize: maxSize) { [weak self] data, _ in
            let image = UIImage(data: data)
            if let image = image {
                fetchResult = .success(image)
                switch imageType {
                case .clubImage(clubId: let key):
                    self?.clubImageCache.appendToAllSmaller(than: imageSize, image, with: key.rawValue)
                case .personImage(clubId: _, personId: let key):
                    self?.personImageCache.appendToAllSmaller(than: imageSize, image, with: key.rawValue)
                }
            } else {
                fetchResult = .failure(StoreError.onFetch)
            }
            dispatchGroup.leave()
        }

        // Observe progress change
        if let progressChangeHandler = progressChangeHandler {
            downloadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                progressChangeHandler(progress)
            }
        }

        // Return image
        return try await withCheckedThrowingContinuation { continuation in
            dispatchGroup.notify(queue: .main) {
                progressChangeHandler?(1.0)
                guard let imageResult = fetchResult else {
                    return continuation.resume(throwing: StoreError.onStore)
                }
                continuation.resume(with: imageResult)
            }
        }
    }

    /// Get image from cache or server
    /// - Parameters:
    ///   - imageType: type of image to get
    ///   - imageSize: size of image to get
    ///   - progressChangeHandler: handles get progress changes
    /// - Returns: cached or fetched image
    func getImage(_ imageType: ImageType, size imageSize: ImageSize, progress progressChangeHandler: ((Double) -> Void)? = nil) async throws -> UIImage {
        switch imageType {
        case .clubImage(clubId: let key):
            if let image = clubImageCache.getImage(with: key.rawValue, imageSize: imageSize) { return image }
        case .personImage(clubId: _, personId: let key):
            if let image = personImageCache.getImage(with: key.rawValue, imageSize: imageSize) { return image }
        }
        return try await fetch(imageType, size: imageSize, progress: progressChangeHandler)
    }

    /// Deletes image with given type
    /// - Parameter imageType: type of image to delete
    /// - Returns: result of delete operation
    @discardableResult func delete(_ imageType: ImageType) async -> OperationResult {

        // Delete images on server
        let result = await withTaskGroup(of: OperationResult.self, returning: OperationResult.self) { group in
            for imageSize in ImageSize.allCases {
                group.async {
                    do {
                        try await Storage.storage(url: Self.storageBucketUrl).reference(withPath: imageType.url(with: imageSize).path).delete()
                    } catch {
                        guard let error = error as NSError?, error.domain == StorageErrorDomain else { return .passed }
                        guard StorageErrorCode(rawValue: error.code) == .objectNotFound else { return .failed }
                    }
                    return .passed
                }
            }
            return await group.contains(.failed) ? .failed : .passed
        }

        // Delete image in cache
        guard result == .passed else { return .failed }
        switch imageType {
        case .clubImage(clubId: let key):
            clubImageCache.deleteFromAll(with: key.rawValue)
        case .personImage(clubId: _, personId: let key):
            personImageCache.deleteFromAll(with: key.rawValue)
        }

        return .passed
    }

    /// Clear cache
    func clear() {
        personImageCache.clearAll()
        clubImageCache.clearAll()
    }
}

/// A cache for any type
struct DataCache<Key, DataType> where Key: Hashable {

    /// Contains personId and associated image
    private struct Metadata<Key, DataType> where Key: Hashable {

        /// Key
        let key: Key

        /// Data
        var data: DataType

        /// Time of adding
        let time: TimeInterval
    }

    /// Maximum number of items in this cache
    private let maxItems: Int?

    /// Data list
    private var dataList = [Metadata<Key, DataType>]()

    /// Init data cache with number of max items
    ///
    /// Cache has no limit if maxItems is nil
    /// - Parameter maxItems: number of max items in data cache
    init(maxItems: Int?) {
        if let maxItems = maxItems {
            self.maxItems = Swift.max(maxItems, 1)
        } else {
            self.maxItems = nil
        }
    }

    /// Get and set data to given key
    subscript(_ key: Key) -> DataType? {
        get {
            dataList.first(where: { $0.key == key })?.data
        }
        set {
            guard let newValue = newValue else { return delete(with: key) }
            if dataList.contains(where: { $0.key == key }) {
                update(newValue, with: key)
            } else {
                append(newValue, with: key)
            }
        }
    }

    /// Append new data to cache
    /// - Parameters:
    ///   - data: data to append to cache
    ///   - key: key of the data to append to cache
    private mutating func append(_ data: DataType, with key: Key) {
        while let maxItems = maxItems, dataList.count >= maxItems { removeEarlist() }
        dataList.append(.init(key: key, data: data, time: Date().timeIntervalSince1970))
    }

    /// Remove earlies data from cache
    private mutating func removeEarlist() {
        guard let earliesMetadata = dataList.min(by: { $0.time < $1.time }) else { return }
        dataList.filtered { $0.key != earliesMetadata.key }
    }

    /// Update data with given key in cache
    /// - Parameters:
    ///   - data: new data to update
    ///   - key: key of the data to update
    private mutating func update(_ data: DataType, with key: Key) {
        dataList.mapped { $0.data = $0.key == key ? data : $0.data }
    }

    /// Delete data with given key from cache
    /// - Parameter key: key of data to delete from cache
    private mutating func delete(with key: Key) {
        dataList.removeAll(where: { $0.key == key })
    }

    /// Clear cache
    mutating func clear() {
        dataList = []
    }
}
