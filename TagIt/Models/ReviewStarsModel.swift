//
//  ReviewStarsModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import FirebaseFirestore
import Foundation

struct ReviewStars: Identifiable, Codable {
    // UserID
    @DocumentID var id: String?
    var barcodeNumber: String
    var reviewStars: Double
    var productName: String
}
