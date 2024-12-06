//
//  BarcodeItemService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-26.
//

import FirebaseFirestore
import Foundation

/// A service responsible for managing barcode items and their associated reviews.
class BarcodeItemService {
    /// The shared singleton instance of `BarcodeItemService`.
    static let shared = BarcodeItemService()

    /// The Firestore database instance used for all database operations.
    private let db = Firestore.firestore()

    /// Fetches all reviews associated with a given barcode.
    ///
    /// - Parameters:
    ///   - barcode: The barcode identifier for which reviews are to be fetched.
    ///   - completion: A closure that receives a `Result` containing an array of `BarcodeItemReview` on success or an `Error` on failure.
    func getReviewsForBarcode(barcode: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection("barcodes")
            .document(barcode)
            .collection("reviews")
            .getDocuments { snapshot, error in
                if let error {
                    completion(.failure(error))
                } else if let snapshot {
                    do {
                        let reviews = try snapshot.documents.map { document in
                            try document.data(as: BarcodeItemReview.self)
                        }
                        completion(.success(reviews))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    completion(.success([])) // No reviews found
                }
            }
    }

    /// Adds a new review for a specific barcode. If the barcode does not exist in the database, it will be created.
    ///
    /// - Parameters:
    ///   - barcode: The barcode identifier to which the review will be added.
    ///   - productName: The name of the product associated with the barcode.
    ///   - review: The `BarcodeItemReview` object containing review details.
    ///   - completion: A closure that receives a `Result` indicating success (`Void`) or an `Error` on failure.
    func addReviewForBarcode(barcode: String, productName: String, review: BarcodeItemReview, completion: @escaping (Result<Void, Error>) -> Void) {
        let barcodeRef = db.collection("barcodes").document(barcode)

        // Check if the barcode exists
        barcodeRef.getDocument { document, error in
            if let error {
                completion(.failure(error))
                return
            }

            if document?.exists == true {
                // Add the review to the existing barcode
                self.addReview(barcodeRef: barcodeRef, review: review, completion: completion)
            } else {
                // Create the barcode and add the review
                barcodeRef.setData(["productName": productName]) { error in
                    if let error {
                        completion(.failure(error))
                        return
                    }

                    self.addReview(barcodeRef: barcodeRef, review: review, completion: completion)
                }
            }
        }
    }

    /// Adds a review to the "reviews" subcollection of a specific barcode.
    ///
    /// - Parameters:
    ///   - barcodeRef: The Firestore `DocumentReference` for the barcode.
    ///   - review: The `BarcodeItemReview` object containing review details.
    ///   - completion: A closure that receives a `Result` indicating success (`Void`) or an `Error` on failure.
    private func addReview(barcodeRef: DocumentReference, review: BarcodeItemReview, completion: @escaping (Result<Void, Error>) -> Void) {
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

    /// Fetches all reviews made by a specific user across all barcodes.
    ///
    /// - Parameters:
    ///   - userId: The unique identifier of the user whose reviews are to be fetched.
    ///   - completion: A closure that receives a `Result` containing an array of `BarcodeItemReview` on success or an `Error` on failure.
    func fetchReviewsByUserId(userId: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection("barcodes").getDocuments { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                completion(.success([])) // No barcodes, so no reviews
                return
            }

            let group = DispatchGroup()
            var allReviews: [BarcodeItemReview] = []
            var fetchError: Error?

            for document in documents {
                group.enter()
                let barcodeId = document.documentID
                self.db.collection("barcodes").document(barcodeId).collection("reviews")
                    .whereField("userID", isEqualTo: userId)
                    .getDocuments { reviewSnapshot, error in
                        if let error {
                            fetchError = error
                            group.leave()
                            return
                        }

                        if let reviewDocs = reviewSnapshot?.documents {
                            let reviews = reviewDocs.compactMap { doc -> BarcodeItemReview? in
                                try? doc.data(as: BarcodeItemReview.self)
                            }
                            allReviews.append(contentsOf: reviews)
                        }
                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                if let error = fetchError {
                    completion(.failure(error))
                } else {
                    completion(.success(allReviews))
                }
            }
        }
    }
}
