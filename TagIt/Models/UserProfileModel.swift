//
//  UserProfileModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    var id: String
    var email: String
    var displayName: String
    var avatarURL: String?
    var score: Int
    var savedDeals: [String]
    var totalUpvotes: Int
    var totalDownvotes: Int
    var totalDeals: Int = 0
    var totalComments: Int = 0
    var rankingPoints: Int = 0
}


