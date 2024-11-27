//
//  ReviewService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-23.
//
import Foundation
import FirebaseFirestore

class ReviewService {
    static let shared = ReviewService()

    private let db = Firestore.firestore()

    // Handle adding a review and creating a barcode if it doesn't exist
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
            if let error = error {
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
                    if let error = error {
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
                if let error = error {
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
     Fetches all existing reviews for a specific user, if it exists.
     
     - Parameters:
        - userID: The ID of the user who reviewed the item.
        - completion: A closure that returns a `Result<[BarcodeItemReview], Error>` indicating success or failure.
     */
    func getAllUserReviews(userID: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        Firestore.firestore().collection(FirestoreCollections.revItem)
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
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
