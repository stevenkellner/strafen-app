//
//  ImageStorage.swift
//  Strafen
//
//  Created by Steven on 11/8/20.
//

import FirebaseStorage

/// Used to storage and fetch images from server
struct ImageStorage {
    
    /// Shared instance for singelton
    static let shared = Self()
    
    /// Private init for singleton
    private init() {}
    
    /// Max size of download data
//    enum DownloadSize { TODO
//
//        /// Small
//        case small
//
//        /// Standard
//        case standard
//
//        /// Big
//        case big
//
//        /// In bytes
//        var inBytes: Int64 {
//            switch self {
//            case .small:
//                return 512 * 1024 // 0.5 MB
//            case .standard:
//                return 5 * 1024 * 1024 // 5 MB
//            case .big:
//                return 30 * 1024 * 1024 // 30 MB
//            }
//        }
//    }

    /// Storage bucket url
    let storageBucketUrl: String = "gs://strafen-app.appspot.com"
    
    /// Compression quality
    let compressionQuality: CGFloat = 0.75
    
    /// Error appears while storing an image
    enum StoreError: Error {
        
        /// Couldn't get data from image
        case noImageData
    }
    
    /// Store image on server
    func store(at url: URL, image: UIImage, handler completionHandler: @escaping (Result<StorageMetadata, Error>) -> Void, progressChangeHandler: ((Double) -> Void)? = nil) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            return completionHandler(.failure(StoreError.noImageData))
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadTask = Storage.storage(url: storageBucketUrl).reference(withPath: url.path).putData(imageData, metadata: metadata) { metadata, error in
            if let metadata = metadata {
                completionHandler(.success(metadata))
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
    func store(at url: URL, image: UIImage, passedHandler: @escaping (StorageMetadata) -> Void, failedHandler: @escaping (Error) -> Void, progressChangeHandler: ((Double) -> Void)? = nil) {
        store(at: url, image: image) { (result: Result<StorageMetadata, Error>) in
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
    
    /// Store image on server
    func store(at url: URL, image: UIImage, taskStateHandler: @escaping (TaskState) -> Void, progressChangeHandler: ((Double) -> Void)? = nil) {
        store(at: url, image: image) { _ in
            taskStateHandler(.passed)
        } failedHandler: { _ in
            taskStateHandler(.failed)
        } progressChangeHandler: { progress in
            if let progressChangeHandler = progressChangeHandler {
                progressChangeHandler(progress)
            }
        }
        
    }
    
    /// Fetch image from server
    func fetch(at url: URL, /*maxSize: DownloadSize,*/ handler completionHandler: @escaping (UIImage?) -> Void, progressChangeHandler: ((Double) -> Void)? = nil) {
        let maxSize: Int64 = 30 * 1024 * 1024 // 30 MB
        let downloadTask = Storage.storage(url: storageBucketUrl).reference(withPath: url.path).getData(maxSize: maxSize) { data, _ in
            let image = UIImage(data: data)
            completionHandler(image)
        }
        if let progressChangeHandler = progressChangeHandler {
            downloadTask.observe(.progress) { snapshot in
                let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                progressChangeHandler(progress)
            }
        }
    }
    
    /// Delete image on server
    func delete(at url: URL, taskStateHandler: @escaping (TaskState) -> Void) {
        Storage.storage(url: storageBucketUrl).reference(withPath: url.path).delete { error in
            let taskState: TaskState = error == nil ? .passed : .failed
            taskStateHandler(taskState)
        }
    }
}
