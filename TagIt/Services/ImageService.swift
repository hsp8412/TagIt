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
    case reviewImage
    
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
    
    // Download image from a URL
    func downloadImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data, let image = UIImage(data: data) {
                print("got valid image")
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "ImageDataError", code: 500, userInfo: nil)))
            }
        }.resume()
    }
}
