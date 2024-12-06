//
//  reviewStars.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-23.
//

import FirebaseFirestore
import Foundation

/**
 Represents the star rating for a product associated with a barcode.

 This model captures the essential details of a product review, including the barcode number,
 the star rating given by the user, and the product's name.
 */
struct ReviewStars: Codable {
    /**
     The unique barcode number of the product being reviewed.

     This identifier links the review to a specific product in the inventory.
     */
    var barcodeNumber: String

    /**
     The star rating given in the review.

     This value typically ranges from 0.0 to 5.0, representing the user's satisfaction level.
     */
    var reviewStars: Double

    /**
     The name of the product being reviewed.

     Provides a human-readable identifier for the product, making it easier to associate reviews
     with their respective products.
     */
    var productName: String
}
