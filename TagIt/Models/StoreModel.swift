//
//  StoreModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-16.
//

import FirebaseFirestore
import Foundation

/**
     Represents a grocery store location.

     This struct encapsulates the essential details of a grocery store, including its geographical coordinates and name.
     It conforms to `Identifiable`, `Codable`, and `Hashable` protocols to facilitate easy integration with SwiftUI views,
     Firestore database operations, and collection handling.

     The `Store` model is utilized in conjunction with Apple MapKit to display and manage grocery store locations within the app.
 */
struct Store: Identifiable, Codable, Hashable {
    /// The unique identifier for the store, automatically managed by Firestore.
    @DocumentID var id: String?

    /// The latitude coordinate of the store's location.
    var latitude: Double

    /// The longitude coordinate of the store's location.
    var longitude: Double

    /// The name of the grocery store.
    var name: String

    /**
         Enumeration to map the struct's properties to Firestore document fields.

         This ensures accurate encoding and decoding between the `Store` struct and Firestore documents.
     */
    enum CodingKeys: String, CodingKey {
        case id
        case latitude
        case longitude
        case name
    }
}
