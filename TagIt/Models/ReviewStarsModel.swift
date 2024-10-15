//
//  ReviewStarsModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct ReviewStars: Identifiable, Decodable {
    // UserID
    @DocumentID var id: String?
    var barcodeNumber: String
    var reviewStars: Double
}
