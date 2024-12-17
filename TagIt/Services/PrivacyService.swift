//
//  PrivacyService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-12-16.
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class PrivacyService {
    static let shared = PrivacyService()
    private init() {}
    
    func getPrivacySettings(userId: String, completion: @escaping (Result<PrivacySettings, Error>) -> Void) {
        FirestoreService.shared.readDocument(
            collectionName: "UserProfile/\(userId)/privacy",
            documentID: "settings",
            modelType: PrivacySettings.self
        ) { result in
            switch result {
            case .success(let settings):
                completion(.success(settings))
            case .failure:
                // Return default settings if none exist
                completion(.success(PrivacySettings.defaultSettings()))
            }
        }
    }
    
    func updatePrivacySettings(settings: PrivacySettings, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirestoreService.shared.createDocument(
            collectionName: "UserProfile/\(userId)/privacy",
            documentID: "settings",
            data: settings,
            completion: { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        )
    }
    
    func deleteUserAccount(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // First ensure we have a valid authenticated user
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "com.tagit.privacy",
                                     code: 401,
                                     userInfo: [NSLocalizedDescriptionKey: "User must be authenticated to delete account"])))
            return
        }
        
        // Verify the authenticated user matches the requested deletion
        guard currentUser.uid == userId else {
            completion(.failure(NSError(domain: "com.tagit.privacy",
                                     code: 403,
                                     userInfo: [NSLocalizedDescriptionKey: "Cannot delete another user's account"])))
            return
        }
        
        // Delete Auth user first
        currentUser.delete { [weak self] authError in
            guard let self = self else { return }
            
            if let authError = authError {
                // Handle specific authentication errors
                let nsError = authError as NSError
                if nsError.domain == AuthErrorDomain {
                    switch nsError.code {
                    case AuthErrorCode.requiresRecentLogin.rawValue:
                        completion(.failure(NSError(domain: "com.tagit.privacy",
                                                 code: 401,
                                                 userInfo: [NSLocalizedDescriptionKey: "Please log in again to delete your account"])))
                    default:
                        completion(.failure(authError))
                    }
                } else {
                    completion(.failure(authError))
                }
                return
            }
            
            // Now clean up user data
            self.cleanupUserData(userId: userId) { error in
                if let error = error {
                    print("Warning: User auth deleted but data cleanup failed: \(error.localizedDescription)")
                }
                completion(.success(()))
            }
        }
    }
    
    /**
     Cleans up all user data after successful authentication deletion.
     This is a separate operation to ensure we don't leave orphaned data.
     
     - Parameter userId: The ID of the user whose data should be cleaned up
     - Parameter completion: Called when cleanup is complete, with any error that occurred
     */
    private func cleanupUserData(userId: String, completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        // Clean up collections in parallel
        let collections = [
            FirestoreCollections.deals,
            FirestoreCollections.userComm,
            FirestoreCollections.revItem,
            FirestoreCollections.votes,
            FirestoreCollections.user
        ]
        
        for collection in collections {
            group.enter()
            deleteUserDataFromCollection(collection, userId: userId) { error in
                if let error = error {
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        // Clean up storage files
        group.enter()
        deleteUserImages(userId: userId) { error in
            if let error = error {
                errors.append(error)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(errors.first) // Return the first error if any occurred
        }
    }
    
    private func deleteUserDataFromCollection(_ collection: String, userId: String, completion: @escaping (Error?) -> Void) {
        let userIdField = collection == FirestoreCollections.votes ? "userId" : "userID"
        
        Firestore.firestore().collection(collection)
            .whereField(userIdField, isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                let group = DispatchGroup()
                var deleteError: Error?
                
                snapshot?.documents.forEach { doc in
                    group.enter()
                    doc.reference.delete { error in
                        if let error = error {
                            deleteError = error
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(deleteError)
                }
            }
    }
    
    private func deleteUserImages(userId: String, completion: @escaping (Error?) -> Void) {
        let imageFolders = [
            ImageService.ImageFolder.avatar.path,
            ImageService.ImageFolder.dealImage.path,
            ImageService.ImageFolder.reviewImage.path
        ]
        
        let group = DispatchGroup()
        var deleteError: Error?
        
        imageFolders.forEach { folder in
            group.enter()
            let storageRef = Storage.storage().reference().child(folder)
            
            storageRef.listAll { result, error in
                if let error = error {
                    deleteError = error
                    group.leave()
                    return
                }
                
                result?.items.forEach { item in
                    if item.name.contains(userId) {
                        item.delete { error in
                            if let error = error {
                                deleteError = error
                            }
                        }
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(deleteError)
        }
    }
}
