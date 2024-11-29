import Foundation
import FirebaseFirestore

class BarcodeItemService {
    static let shared = BarcodeItemService()
    
    private let db = Firestore.firestore()
    
    // Fetch all reviews for a given barcode
    func getReviewsForBarcode(barcode: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection("barcodes")
            .document(barcode)
            .collection("reviews")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else if let snapshot = snapshot {
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
    
    // Add a review for a barcode. If barcode doesn't exist, create it.
    func addReviewForBarcode(barcode: String, productName: String, review: BarcodeItemReview, completion: @escaping (Result<Void, Error>) -> Void) {
        let barcodeRef = db.collection("barcodes").document(barcode)
        
        // Check if the barcode exists
        barcodeRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if document?.exists == true {
                // Add the review to the existing barcode
                self.addReview(barcodeRef: barcodeRef, review: review, completion: completion)
            } else {
                // Create the barcode and add the review
                barcodeRef.setData(["productName": productName]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    self.addReview(barcodeRef: barcodeRef, review: review, completion: completion)
                }
            }
        }
    }
    
    // Helper function to add a review to a barcode's "reviews" subcollection
    private func addReview(barcodeRef: DocumentReference, review: BarcodeItemReview, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    func fetchReviewsByUserId(userId: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection("barcodes").getDocuments { snapshot, error in
            if let error = error {
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
                        if let error = error {
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
