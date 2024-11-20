//
//  UserProfileModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var avatarURL: String?
    var score: Int
    var savedDeals: [String]
}

