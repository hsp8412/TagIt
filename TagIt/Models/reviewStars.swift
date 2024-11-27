//
//  ReviewStars.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-23.
//

import Foundation
import FirebaseFirestore

struct ReviewStars: Codable {
    var barcodeNumber: String
    var reviewStars: Double
    var productName: String
}
