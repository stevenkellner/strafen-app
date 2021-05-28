//
//  ImageStorage.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import FirebaseStorage

/// Used to storage and fetch images from server
class ImageStorage {

    /// Shared instance for singelton
    static let shared = ImageStorage()

    /// Private init for singleton
    private init() {}

    /// Image type
    enum ImageType {

        /// Club image
        case clubImage(clubId: Club.ID)

        /// Person image
        case personImage(clubId: Club.ID, personId: Person.ID)

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
    let storageBucketUrl: String = "gs://strafen-app.appspot.com"

    /// Compression quality
    let compressionQuality: CGFloat = 0.85

    /// Error appears while storing an image
    enum StoreError: Error {

        /// Couldn't get data from image
        case noImageData
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
        mutating func appendToAll(_ image: UIImage, with key: UUID) {
            smallImages[key] = image
            standardImages[key] = image
            bigImages[key] = image
            originalImages[key] = image
        }

        /// Append image to all caches smaller or equal size than given image size
        mutating func appendToAllSmaller(than imageSize: ImageSize, _ image: UIImage, with key: UUID) {
            if imageSize >= .original { originalImages[key] = image }
            if imageSize >= .thumbBig { bigImages[key] = image }
            if imageSize >= .thumbStandard { standardImages[key] = image }
            if imageSize >= .thumbsSmall { smallImages[key] = image }
        }

        /// Delete from all
        mutating func deleteFromAll(with key: UUID) {
            smallImages[key] = nil
            standardImages[key] = nil
            bigImages[key] = nil
            originalImages[key] = nil
        }

        /// Get image
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

    /// Store image on server
    func store(_ image: UIImage,
               of imageType: ImageType,
               handler completionHandler: @escaping (Result<StorageMetadata, Error>) -> Void,
               progressChangeHandler: ((Double) -> Void)? = nil) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return completionHandler(.failure(StoreError.noImageData))
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadTask = Storage.storage(url: storageBucketUrl).reference(withPath: imageType.url.path).putData(imageData, metadata: metadata) { [weak self] metadata, error in
            if let metadata = metadata {
                completionHandler(.success(metadata))
                switch imageType {
                case .clubImage(clubId: let key):
                    self?.clubImageCache.appendToAll(image, with: key.rawValue)
                case .personImage(clubId: _, personId: let key):
                    self?.personImageCache.appendToAll(image, with: key.rawValue)
                }
            } else if let error = error {
                completionHandler(.failure(error))
            } else {
                fatalError("Storage call returns no metadata and no error.")
            }
        }
        if let progressChangeHandler = progressChangeHandler {
            uploadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                progressChangeHandler(progress)
            }
        }
    }

    /// Store image on server
    func store(_ image: UIImage,
               of imageType: ImageType,
               passedHandler: @escaping (StorageMetadata) -> Void,
               failedHandler: @escaping (Error) -> Void,
               progressChangeHandler: ((Double) -> Void)? = nil) {
        store(image, of: imageType) { (result: Result<StorageMetadata, Error>) in
            switch result {
            case .success(let metadata):
                passedHandler(metadata)
            case .failure(let error):
                failedHandler(error)
            }
        } progressChangeHandler: { progress in
            if let progressChangeHandler = progressChangeHandler {
                progressChangeHandler(progress)
            }
        }
    }

    /// Fetch image from server
    private func fetch(_ imageType: ImageType,
                       size imageSize: ImageSize,
                       handler completionHandler: @escaping (UIImage?) -> Void,
                       progressChangeHandler: ((Double) -> Void)? = nil) {
        let maxSize: Int64 = 30 * 1024 * 1024 // 30 MB
        let downloadTask = Storage.storage(url: storageBucketUrl).reference(withPath: imageType.url(with: imageSize).path).getData(maxSize: maxSize) { [weak self] data, _ in
            let image = UIImage(data: data)
            if let image = image {
                switch imageType {
                case .clubImage(clubId: let key):
                    self?.clubImageCache.appendToAllSmaller(than: imageSize, image, with: key.rawValue)
                case .personImage(clubId: _, personId: let key):
                    self?.personImageCache.appendToAllSmaller(than: imageSize, image, with: key.rawValue)
                }
            }
            completionHandler(image)
        }
        if let progressChangeHandler = progressChangeHandler {
            downloadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                progressChangeHandler(progress)
            }
        }
    }

    /// Get image from cache or from server
    func getImage(_ imageType: ImageType,
                  size imageSize: ImageSize,
                  handler completionHandler: @escaping (UIImage?) -> Void,
                  progressChangeHandler: ((Double) -> Void)? = nil) {
        switch imageType {
        case .clubImage(clubId: let key):
            if let image = clubImageCache.getImage(with: key.rawValue, imageSize: imageSize) { return completionHandler(image) }
        case .personImage(clubId: _, personId: let key):
            if let image = personImageCache.getImage(with: key.rawValue, imageSize: imageSize) { return completionHandler(image) }
        }
        fetch(imageType, size: imageSize, handler: completionHandler, progressChangeHandler: progressChangeHandler)
    }

    /// Delete image on server
    func delete(_ imageType: ImageType,
                taskStateHandler: @escaping (TaskState) -> Void) {
        var taskState: TaskState = .passed
        let dispatchGroup = DispatchGroup()
        for imageSize in ImageSize.allCases {
            dispatchGroup.enter()
            Storage.storage(url: storageBucketUrl).reference(withPath: imageType.url(with: imageSize).path).delete { error in
                if let error = error as NSError?, error.domain == StorageErrorDomain {
                    let errorCode = StorageErrorCode(rawValue: error.code)
                    if errorCode != .objectNotFound {
                        taskState = .failed
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [weak self] in
            taskStateHandler(taskState)
            if taskState == .passed {
                switch imageType {
                case .clubImage(clubId: let key):
                    self?.clubImageCache.deleteFromAll(with: key.rawValue)
                case .personImage(clubId: _, personId: let key):
                    self?.personImageCache.deleteFromAll(with: key.rawValue)
                }
            }
        }
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

    /// Append new data
    private mutating func append(_ data: DataType, with key: Key) {
        while let maxItems = maxItems, dataList.count >= maxItems { removeEarlist() }
        dataList.append(.init(key: key, data: data, time: Date().timeIntervalSince1970))
    }

    /// Remove earlies data
    private mutating func removeEarlist() {
        guard let earliesMetadata = dataList.min(by: { $0.time < $1.time }) else { return }
        dataList.filtered { $0.key != earliesMetadata.key }
    }

    /// Update data
    private mutating func update(_ data: DataType, with key: Key) {
        dataList.mapped { $0.data = $0.key == key ? data : $0.data }
    }

    /// Delete data
    private mutating func delete(with key: Key) {
        dataList.removeAll(where: { $0.key == key })
    }

    /// Clear cache
    mutating func clear() {
        dataList = []
    }
}
