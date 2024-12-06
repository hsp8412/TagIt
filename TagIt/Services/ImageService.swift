//
//  ImageService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-20.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

/**
 A service responsible for handling image uploads and downloads.

 This service facilitates uploading images to Firebase Storage when users take pictures for deals or barcode reviews
 and downloading images from provided URLs. It ensures that images are stored in the appropriate Firebase Storage folders
 and provides easy access to retrieve them when needed.
 */
class ImageService {
    /// The shared singleton instance of `ImageService`.
    static let shared = ImageService()

    /// Private initializer to enforce the singleton pattern.
    private init() {}

    /**
         Enumeration representing different folders where images can be stored in Firebase Storage.

         - avatar: Folder for storing user avatar images.
         - dealImage: Folder for storing images related to deals posted by users.
         - productImage: Folder for storing product images.
         - reviewImage: Folder for storing images associated with barcode reviews.
     */
    enum ImageFolder: String {
        case avatar
        case dealImage
        case productImage
        case reviewImage

        /**
             Returns the raw string value associated with the enum case, representing the folder path in Firebase Storage.

             - Returns: A `String` representing the folder path.
         */
        var path: String {
            rawValue
        }
    }

    /**
         Uploads an image to a specified folder in Firebase Storage.

         This method is used when a user takes a picture for a deal or a barcode review, ensuring that images are stored
         in the appropriate Firebase Storage folder.

         - Parameters:
             - image: The `UIImage` to be uploaded.
             - folder: The `ImageFolder` enum case indicating the target folder in Firebase Storage.
             - fileName: The desired filename for the uploaded image.
             - completion: A closure that receives a `Result<String, Error>`, containing the download URL string on success or an `Error` on failure.

         - Returns: Void. The result is delivered asynchronously through the `completion` closure.
     */
    func uploadImage(_ image: UIImage, folder: ImageFolder, fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Convert the UIImage to JPEG data with compression quality of 0.8
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageDataError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."])))
            return
        }

        // Create a reference to the desired location in Firebase Storage
        let storageRef = Storage.storage().reference().child("\(folder.path)/\(fileName).jpg")

        // Upload the image data to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error {
                // If there's an error during upload, return failure
                completion(.failure(error))
                return
            }

            // Retrieve the download URL of the uploaded image
            storageRef.downloadURL { url, error in
                if let error {
                    // If there's an error retrieving the URL, return failure
                    completion(.failure(error))
                } else if let downloadURL = url {
                    // On success, return the download URL as a string
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }

    /**
         Downloads an image from a given URL.

         - Parameters:
             - urlString: The `String` representation of the image URL.
             - completion: A closure that receives a `Result<UIImage, Error>`, containing the downloaded `UIImage` on success or an `Error` on failure.

         - Returns: Void. The result is delivered asynchronously through the `completion` closure.
     */
    func downloadImage(from urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Validate the URL string
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "The provided URL string is invalid."])))
            return
        }

        // Create a data task to download the image data
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                // If there's an error during download, return failure
                completion(.failure(error))
                return
            }

            // Validate and convert the downloaded data to a UIImage
            if let data, let image = UIImage(data: data) {
                print("Successfully downloaded image.")
                completion(.success(image))
            } else {
                // If data conversion fails, return failure
                completion(.failure(NSError(domain: "ImageDataError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to image."])))
            }
        }.resume()
    }
}
