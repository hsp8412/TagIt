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

    /**
     Handles adding, updating, or removing a review for a specific barcode item by a user.

     - Parameters:
        - userId: The ID of the user who is submitting the review.
        - barcodeNumber: The barcode number of the item being reviewed.
        - reviewStars: The number of stars (rating) the user is giving the item.
        - productName: The name of the product being reviewed.
        - reviewTitle: The title of the review.
        - reviewText: The text content of the review.
        - photoURL: The URL of the photo associated with the review.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
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
        let reviewId = "\(userId)_\(barcodeNumber)" // Unique identifier for each review (userId + barcodeNumber)

        // Create or update the review
        let review = BarcodeItemReview(
            id: reviewId,
            userID: userId,
            photoURL: photoURL,
            reviewStars: reviewStars,
            productName: productName,
            barcodeNumber: barcodeNumber,
            dateTime: nil, // ServerTimestamp will set this
            reviewTitle: reviewTitle,
            reviewText: reviewText
        )

        do {
            try db.collection(FirestoreCollections.revItem)
                .document(reviewId)
                .setData(from: review) { [weak self] error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // After creating or updating, recalculate the overall review stars for the item
                        self?.updateReviewStars(for: barcodeNumber, productName: productName, completion: completion)
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }

    /**
     Fetches an existing review for a specific item by a user, if it exists.

     - Parameters:
        - userId: The ID of the user who reviewed the item.
        - barcodeNumber: The barcode number of the item being reviewed.
        - completion: A closure that returns a `Result<BarcodeItemReview?, Error>` indicating success or failure.
     */
    func getUserReview(userId: String, barcodeNumber: String, completion: @escaping (Result<BarcodeItemReview?, Error>) -> Void) {
        let reviewId = "\(userId)_\(barcodeNumber)"
        db.collection(FirestoreCollections.revItem)
            .document(reviewId)
            .getDocument { documentSnapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    do {
                        let review = try documentSnapshot.data(as: BarcodeItemReview.self)
                        completion(.success(review))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.success(nil)) // No review exists for this item
                }
            }
    }

    /**
     Recalculates the overall review stars for a specific barcode item after a review has been added, updated, or removed.

     - Parameters:
        - barcodeNumber: The barcode number of the item being reviewed.
        - productName: The name of the product being reviewed.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    private func updateReviewStars(for barcodeNumber: String, productName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        getReviews(for: barcodeNumber) { [weak self] result in
            switch result {
            case .success(let reviews):
                guard !reviews.isEmpty else {
                    // If there are no reviews left, remove the overall review document
                    self?.db.collection(FirestoreCollections.revStars)
                        .document(barcodeNumber)
                        .delete { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    return
                }

                let totalStars = reviews.reduce(0) { $0 + $1.reviewStars }
                let averageStars = totalStars / Double(reviews.count)

                let updatedReviewStars = ReviewStars(
                    barcodeNumber: barcodeNumber,
                    reviewStars: averageStars,
                    productName: productName
                )

                do {
                    try self?.db.collection(FirestoreCollections.revStars)
                        .document(barcodeNumber)
                        .setData(from: updatedReviewStars) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /**
     Fetches all reviews for a specific barcode item.

     - Parameters:
        - barcodeNumber: The barcode number of the item being reviewed.
        - completion: A closure that returns a `Result<[BarcodeItemReview], Error>` indicating success or failure.
     */
    func getReviews(for barcodeNumber: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection(FirestoreCollections.revItem)
            .whereField("barcodeNumber", isEqualTo: barcodeNumber)
            .order(by: "dateTime", descending: true) // Sort reviews by date, newest first
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let reviews = snapshot.documents.compactMap { doc -> BarcodeItemReview? in
                        try? doc.data(as: BarcodeItemReview.self)
                    }
                    completion(.success(reviews))
                } else {
                    completion(.success([]))
                }
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
