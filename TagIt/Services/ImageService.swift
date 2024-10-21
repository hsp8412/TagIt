//
//  ImageService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

enum ImageFolder: String {
    case avatar
    case dealImage
    case productImage
    
    var path: String {
        return self.rawValue
    }
}


class ImageService {
    
    static let shared = ImageService()
    
    private init() {}
    
    // General function to upload an image to a specified folder
    func uploadImage(_ image: UIImage, folder: ImageFolder, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageDataError", code: 400, userInfo: nil)))
            return
        }
        
        let storageRef = Storage.storage().reference().child("\(folder.path)/\(fileName).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
}
