//
//  SignInClubInput.swift
//  Strafen
//
//  Created by Steven on 10/26/20.
//

import SwiftUI
import FirebaseFunctions

/// View to input all club properties
struct SignInClubInput: View {
    
    /// Club credentials
    struct ClubCredentials {
        
        /// Club name
        var clubName: String = ""
        
        /// Club identifier
        var clubIdentifier: String = ""
        
        /// Club image
        var image: UIImage? = nil
        
        /// Type of club name textfield error
        var clubNameErrorMessages: ErrorMessages? = nil
        
        /// Type of club identifier error
        var clubIdentifierErrorMessages: ErrorMessages? = nil
        
        /// Check if club name is empty
        @discardableResult mutating func evaluteClubNameError() -> Bool {
            if clubName.isEmpty {
                clubNameErrorMessages = .emptyField
            } else {
                clubNameErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if club identifier is empty
        @discardableResult mutating func evaluateClubIdentifierError() -> Bool {
            if clubIdentifier.isEmpty {
                clubIdentifierErrorMessages = .emptyField
            } else {
                clubIdentifierErrorMessages = nil
                return false
            }
            return true
        }
        
        /// Check if any errors occurs
        mutating func checkErrors() -> Bool {
            var isError = false
            isError = evaluteClubNameError() || isError
            isError = evaluateClubIdentifierError() || isError
            return isError
        }
    }
    
    /// Club credentials
    @State var clubCredentials = ClubCredentials()
    
    /// State of the connection
    @State var connectionState: ConnectionState = .passed
    
    /// Progess of image upload
    @State var imageUploadProgess: Double? = nil
    
    /// Screen size of this view
    @State var screenSize: CGSize?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Back button
                BackButton()
                
                VStack(spacing: 0) {
                    
                    // Bar to wipe sheet down
                    SheetBar()
                    
                    // Header
                    Header("Neuer Verein")
                        .padding(.top, 30)
                    
                    // Club properties input
                    ClubPropertiesInput(clubCredentials: $clubCredentials, imageUploadProgess: $imageUploadProgess)
                        .animation(.default)
                    
                    Spacer()
                    
                    // Confirm Button
                    ConfirmButton()
                        .title("Erstellen")
                        .connectionState($connectionState)
                        .onButtonPress(handleConfirmButton)
                        .padding(.bottom, 50)
                    
                }
            }.screenSize($screenSize, geometry: geometry)
        }
    }
    
    /// Handles confirm button press
    func handleConfirmButton() {
        guard connectionState != .loading else { return }
        connectionState = .loading
        
        guard !clubCredentials.checkErrors() else {
            return connectionState = .failed
        }
        
        // Id of new club
        let clubId = UUID()
        
        // Check if club identifer already exists
        checkClubIdentifierExists {
                
            // Set club image
            setClubImage(of: clubId) {
                
                // Create new club in database
                createNewClub(of: clubId)
                
            }
        }
    }
    
    /// Checks if club identifier already exists
    func checkClubIdentifierExists(doesnotExistsHandler: @escaping () -> Void) {
        let existClubCallItem = ClubIdentifierAlreadyExistsCall(identifier: clubCredentials.clubIdentifier)
        FunctionCaller.shared.call(existClubCallItem) { (clubExists: ClubIdentifierAlreadyExistsCall.CallResult) in
            if !clubExists {
                doesnotExistsHandler()
            } else {
                clubCredentials.clubIdentifierErrorMessages = .identifierAlreadyExists
                connectionState = .failed
            }
        } failedHandler: { _ in
            clubCredentials.clubNameErrorMessages = .internalErrorSignIn
            connectionState = .failed
        }
    }
    
    /// Set club image
    func setClubImage(of clubId: UUID, completionHandler: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        if let image = clubCredentials.image {
            imageUploadProgess = .zero
            dispatchGroup.enter()
            ImageStorage.shared.store(at: .clubImage(with: clubId), image: image) { _ in
                dispatchGroup.leave()
                imageUploadProgess = nil
            } failedHandler: { _ in
                clubCredentials.clubNameErrorMessages = .internalErrorSignIn
                connectionState = .failed
                imageUploadProgess = nil
            } progressChangeHandler: { progress in
                imageUploadProgess = progress
            }
        }
        dispatchGroup.notify(queue: .main) {
            completionHandler()
        }
    }
    
    /// Create new club in database
    func createNewClub(of clubId: UUID) {
        
        // New club call item
        let cachedProperty = SignInCache.shared.cachedStatus?.property as! SignInCache.PropertyUserIdName
        let personId = UUID()
        let callItem = NewClubCall(cachedProperties: cachedProperty, clubCredentials: clubCredentials, clubId: clubId, personId: personId)
        
        // Create new club in database
        FunctionCaller.shared.call(callItem) { _ in
            connectionState = .passed
            imageUploadProgess = nil
            SignInCache.shared.setState(to: nil)
            NewSettings.shared.properties.person = .init(personId: personId, clubId: clubId, isCashier: true)
        } failedHandler: { error in
            handleCallError(error: error)
        }
        
    }
    
    /// Handles error of get club id call
    func handleCallError(error: Error) {
        guard let error = error as NSError?, error.domain == FunctionsErrorDomain else {
            return clubCredentials.clubNameErrorMessages = .internalErrorSignIn
        }
        let errorCode = FunctionsErrorCode(rawValue: error.code)
        switch errorCode {
        case .alreadyExists:
            clubCredentials.clubIdentifierErrorMessages = .identifierAlreadyExists
        default:
            clubCredentials.clubNameErrorMessages = .internalErrorSignIn
        }
        connectionState = .failed
        imageUploadProgess = nil
    }
    
    /// Club properties input
    struct ClubPropertiesInput: View {
        
        /// Club credentials
        @Binding var clubCredentials: ClubCredentials
        
        /// Progess of image upload
        @Binding var imageUploadProgess: Double?
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 5) {
                        
                        // Image
                        ImageSelector(image: $clubCredentials.image, uploadProgress: $imageUploadProgess)
                            .frame(width: 150, height: 150)
                            .padding(.bottom, 20)
                        
                        // Progress bar
                        if let imageUploadProgess = imageUploadProgess {
                            VStack(spacing: 5) {
                                Text("Bild hochladen")
                                    .configurate(size: 15)
                                    .padding(.horizontal, 20)
                                    .lineLimit(1)
                                ProgressView(value: imageUploadProgess)
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(width: UIScreen.main.bounds.width * 0.95)
                            }
                        }
                        
                    }
                    
                    // Club name
                    VStack(spacing: 5) {
                        
                        // Title
                        Title("Vereinsname")
                        
                        // Text Field
                        CustomTextField()
                            .title("Vereinsname")
                            .textBinding($clubCredentials.clubName)
                            .errorMessages($clubCredentials.clubNameErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                clubCredentials.evaluteClubNameError()
                            }
                        
                    }
                    
                    // Club identifier
                    VStack(spacing: 5) {
                        
                        // Title
                        Title("Vereinskennung")
                        
                        // Text Field
                        CustomTextField()
                            .title("Vereinskennung")
                            .textBinding($clubCredentials.clubIdentifier)
                            .errorMessages($clubCredentials.clubIdentifierErrorMessages)
                            .textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 50)
                            .onCompletion {
                                clubCredentials.evaluateClubIdentifierError()
                            }
                        
                        // Text
                        Text("Benutze die eindeutige Kennung um andere Spieler hinzuzufügen.")
                            .configurate(size: 20)
                            .padding(.horizontal, 20)
                            .lineLimit(2)
                        
                    }
                    
                }.padding(.vertical, 10)
                .keyboardAdaptiveOffset
            }.padding(.vertical, 10)
        }
    }
}


// TODO
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

// Extension of URL to get path to club and person image files in server
extension URL {
    
    /// Path to club image file in server
    static func clubImage(with id: UUID) -> URL {
        URL(string: "images")!
            .appendingPathComponent("club")
            .appendingPathComponent(id.uuidString.uppercased())
    }
    
    /// Path to person image file in server
    static func personImage(with id: UUID, clubId: UUID) -> URL {
        URL(string: "images")!
            .appendingPathComponent("person")
            .appendingPathComponent(clubId.uuidString.uppercased())
            .appendingPathComponent(id.uuidString.uppercased())
    }
}
