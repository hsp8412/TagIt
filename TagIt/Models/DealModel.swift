//
//  DealModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct Deal: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var photoURL: String
    var productText: String
    var postText: String
    var price: Double
    var location: String
    var date: String
    var commentIDs: [String]
    var upvote: Int
    var downvote: Int
    var store: Store?
    var locationId:String?
    
    @ServerTimestamp var dateTime: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case photoURL
        case productText
        case postText
        case price
        case location
        case date
        case commentIDs
        case upvote
        case downvote
        case locationId
        case dateTime // Ensure dateTime is saved as a timestamp
        // Exclude 'store' from Firestore encoding
    }
}

struct DealHit: Codable {
    let objectID: String
    let productText: String?
    let commentIDs: [String]?
    let date: String?
    let downvote: Int?
    let photoURL: String?
    let postText: String?
    let price: Double?
    let upvote: Int?
    let userID: String?
    let dateTime: Int?
    let location: String?
    let locationId: String?
}
