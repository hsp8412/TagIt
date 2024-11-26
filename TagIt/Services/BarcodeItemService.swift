import Foundation
import FirebaseFirestore

class BarcodeItemService {
    static let shared = BarcodeItemService()
    
    private let db = Firestore.firestore()

    func getBarcodeItemsByBarcode(barcode: String, completion: @escaping (Result<[BarcodeItemReview], Error>) -> Void) {
        db.collection(FirestoreCollections.revItem)
            .whereField("barcodeNumber", isEqualTo: barcode) 
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error)) 
                } else if let snapshot = snapshot {
                    do {
                        let barcodeItems = try snapshot.documents.map { document in
                            try document.data(as: BarcodeItemReview.self) 
                        }
                        completion(.success(barcodeItems)) 
                    } catch {
                        completion(.failure(error)) 
                    }
                } else {
                    completion(.failure(NSError(domain: "BarcodeItemService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No BarcodeItem found"])))
                }
            }
    }

    func addBarcodeItem(barcodeItem: BarcodeItemReview, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            _ = try db.collection(FirestoreCollections.revItem)
                .addDocument(from: barcodeItem) { error in
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


}
