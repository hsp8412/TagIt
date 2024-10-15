//
//  BarcodeItemReviewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct Review: Identifiable, Decodable {
    @DocumentID var id: String?
    var userID: String
    var photoURL: String
    var reviewStars: Double
    var productName: String
    var commentIDs: [String]
}
