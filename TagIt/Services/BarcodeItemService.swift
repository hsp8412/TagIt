import Foundation
import FirebaseFirestore

class BarcodeItemService {
    static let shared = BarcodeItemService()
    
    private let db = Firestore.firestore()

    func getBarcodeItemsByBarcode(barcode: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection(FirestoreCollections.revItem)
            .whereField("barcodeNumber", isEqualTo: barcode) // Query all documents with the matching barcodeNumber
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error)) // Return failure if an error occurs
                } else if let snapshot = snapshot {
                    do {
                        let barcodeItems = try snapshot.documents.map { document in
                            try document.data(as: BarcodeItemReview.self) // Decode each document into BarcodeItemReview
                        }
                        completion(.success(barcodeItems)) // Return the list of items on success
                    } catch {
                        completion(.failure(error)) // Handle decoding errors
                    }
                } else {
                    completion(.failure(NSError(domain: "BarcodeItemService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No BarcodeItem found"])))
                }
            }
    }

    func addBarcodeItem(barcodeItem: BarcodeItemReview, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            // Add to the collection with auto-generated ID
            _ = try db.collection(FirestoreCollections.revItem)
                .addDocument(from: barcodeItem) { error in
                    if let error = error {
                        completion(.failure(error)) // Return error if adding fails
                    } else {
                        completion(.success(())) // Return success
                    }
                }
        } catch {
            completion(.failure(error)) // Handle serialization errors
        }
    }


}