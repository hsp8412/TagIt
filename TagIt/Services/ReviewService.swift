//
//  reviewService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-23.
//
import Foundation
import FirebaseFirestore

class ReviewService {
    static let shared = ReviewService()

    /**
     Handles adding, updating, or removing a review for a specific barcode item by a user.
     
     - Parameters:
        - userId: The ID of the user who is submitting the review.
        - barcodeNumber: The barcode number of the item being reviewed.
        - reviewStars: The number of stars (rating) the user is giving the item.
        - productName: The name of the product being reviewed.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    func handleReview(userId: String, barcodeNumber: String, reviewStars: Double, productName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let reviewId = "\(userId)_\(barcodeNumber)" // Unique identifier for each review (userId + barcodeNumber)
        
        // Check if the user has already reviewed this item
        getUserReview(userId: userId, barcodeNumber: barcodeNumber) { result in
            switch result {
            case .success(let existingReview):
                if let existingReview = existingReview {
                    if existingReview.reviewStars == reviewStars {
                        // If the user clicks the same review stars, remove the review (delete it)
                        FirestoreService.shared.deleteDocument(collectionName: FirestoreCollections.revItem, documentID: reviewId) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                // After deletion, update the overall review stars for the item
                                self.updateReviewStars(for: barcodeNumber, completion: completion)
                            }
                        }
                    } else {
                        // If the user updates their review, replace it with the new stars
                        let updatedReview = BarcodeItemReview(userID: userId, photoURL: "", reviewStars: reviewStars, productName: productName, commentIDs: [], barcodeNumber: barcodeNumber)
                        FirestoreService.shared.createDocument(collectionName: FirestoreCollections.revItem, documentID: reviewId, data: updatedReview) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                // After updating, recalculate the overall review stars for the item
                                self.updateReviewStars(for: barcodeNumber, completion: completion)
                            }
                        }
                    }
                } else {
                    // If no review exists, create a new one
                    let newReview = BarcodeItemReview(userID: userId, photoURL: "", reviewStars: reviewStars, productName: productName, commentIDs: [], barcodeNumber: barcodeNumber)
                    FirestoreService.shared.createDocument(collectionName: FirestoreCollections.revItem, documentID: reviewId, data: newReview) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            // After creating, recalculate the overall review stars for the item
                            self.updateReviewStars(for: barcodeNumber, completion: completion)
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
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
        FirestoreService.shared.readDocument(collectionName: FirestoreCollections.revItem, documentID: reviewId, modelType: BarcodeItemReview.self) { result in
            switch result {
            case .success(let review):
                completion(.success(review))
            case .failure(let error):
                if (error as NSError).code == FirestoreErrorCode.notFound.rawValue {
                    completion(.success(nil)) // No review exists for this item
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    /**
     Recalculates the overall review stars for a specific barcode item after a review has been added, updated, or removed.
     
     - Parameters:
        - barcodeNumber: The barcode number of the item being reviewed.
        - completion: A closure that returns a `Result<Void, Error>` indicating success or failure.
     */
    private func updateReviewStars(for barcodeNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        getReviews(for: barcodeNumber) { result in
            switch result {
            case .success(let reviews):
                let totalStars = reviews.reduce(0) { $0 + $1.reviewStars }
                let averageStars = totalStars / Double(reviews.count)
                
                let updatedReviewStars = ReviewStars(barcodeNumber: barcodeNumber, reviewStars: averageStars, productName: reviews.first?.productName ?? "")
                
                FirestoreService.shared.createDocument(
                    collectionName: FirestoreCollections.revStars,
                    documentID: barcodeNumber,
                    data: updatedReviewStars
                ) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
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
        FirestoreService.shared.db.collection(FirestoreCollections.revItem)
            .whereField("barcodeNumber", isEqualTo: barcodeNumber)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
                    let reviews = snapshot.documents.compactMap { doc -> BarcodeItemReview? in
                        try? doc.data(as: BarcodeItemReview.self)
                    }
                    completion(.success(reviews))
                }
            }
    }
}
