//
//  BarcodeItemReviewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct BarcodeItemReview: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var photoURL: String
    var reviewStars: Double
    var productName: String
    var barcodeNumber: String
    @ServerTimestamp var dateTime: Timestamp?
    var reviewTitle: String
    var reviewText: String
}
