//
//  ReviewService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-23.
//

import FirebaseFirestore
import Foundation

/**
 A service responsible for managing reviews within the TagIt application.

 This service provides functionalities to handle adding reviews, creating barcodes if they don't exist,
 and fetching all reviews associated with a specific user.
 */
class ReviewService {
    /**
     The shared singleton instance of `ReviewService`.

     This ensures that a single, consistent instance of the service is used throughout the application.
     */
    static let shared = ReviewService()

    /**
     The Firestore database instance used for all database operations.

     This instance facilitates interactions with Firestore collections and documents.
     */
    private let db = Firestore.firestore()

    /**
     Handles adding a review and creating a barcode if it doesn't exist.

     - Parameters:
       - userId: The ID of the user submitting the review.
       - barcodeNumber: The barcode number associated with the product being reviewed.
       - reviewStars: The star rating given in the review.
       - productName: The name of the product being reviewed.
       - reviewTitle: The title of the review.
       - reviewText: The detailed text of the review.
       - photoURL: The URL of the photo associated with the review.
       - completion: A closure that receives a `Result<Void, Error>` indicating success or failure.

     This function checks if the barcode exists in Firestore. If it does, it adds the review to the existing barcode.
     If the barcode doesn't exist, it creates a new barcode document and then adds the review.
     */
    func handleReview(
        userId: String,
        barcodeNumber: String,
        reviewStars: Double,
        productName: String,
        reviewTitle: String,
        reviewText: String,
        photoURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let barcodeRef = db.collection("barcodes").document(barcodeNumber)

        barcodeRef.getDocument { document, error in
            if let error {
                completion(.failure(error))
                return
            }

            if document?.exists == true {
                // Barcode exists, add the review
                self.addReviewToBarcode(
                    barcodeRef: barcodeRef,
                    userId: userId,
                    reviewStars: reviewStars,
                    reviewTitle: reviewTitle,
                    reviewText: reviewText,
                    photoURL: photoURL,
                    completion: completion
                )
            } else {
                // Create barcode and add the review
                barcodeRef.setData(["productName": productName]) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }

                    self.addReviewToBarcode(
                        barcodeRef: barcodeRef,
                        userId: userId,
                        reviewStars: reviewStars,
                        reviewTitle: reviewTitle,
                        reviewText: reviewText,
                        photoURL: photoURL,
                        completion: completion
                    )
                }
            }
        }
    }

    /**
     Adds a review to a specific barcode's "reviews" subcollection in Firestore.

     - Parameters:
       - barcodeRef: The `DocumentReference` of the barcode to which the review will be added.
       - userId: The ID of the user submitting the review.
       - reviewStars: The star rating given in the review.
       - reviewTitle: The title of the review.
       - reviewText: The detailed text of the review.
       - photoURL: The URL of the photo associated with the review.
       - completion: A closure that receives a `Result<Void, Error>` indicating success or failure.

     This helper function creates a `BarcodeItemReview` object and adds it to the "reviews" subcollection of the specified barcode.
     */
    private func addReviewToBarcode(
        barcodeRef: DocumentReference,
        userId: String,
        reviewStars: Double,
        reviewTitle: String,
        reviewText: String,
        photoURL: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let review = BarcodeItemReview(
            id: nil,
            userID: userId,
            photoURL: photoURL,
            reviewStars: reviewStars,
            productName: "", // Use productName if available
            barcodeNumber: barcodeRef.documentID,
            dateTime: nil,
            reviewTitle: reviewTitle,
            reviewText: reviewText
        )

        do {
            _ = try barcodeRef.collection("reviews").addDocument(from: review) { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    /**
     Fetches all existing reviews for a specific user, if they exist.

     - Parameters:
       - userID: The ID of the user who reviewed the item.
       - completion: A closure that returns a `Result<[BarcodeItemReview], Error>` indicating success or failure.
     */
    func getAllUserReviews(userID: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        Firestore.firestore().collection(FirestoreCollections.revItem)
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                } else if let snapshot {
                    let reviews = snapshot.documents.compactMap { doc -> BarcodeItemReview? in
                        try? doc.data(as: BarcodeItemReview.self)
                    }
                    completion(.success(reviews))
                } else {
                    completion(.failure(NSError(domain: "ReviewService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No reviews found for this user"])))
                }
            }
    }
}
