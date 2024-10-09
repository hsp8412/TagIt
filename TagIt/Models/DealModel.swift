//
//  DealModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct Deal: Identifiable, Decodable {
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
}
