//
//  UserProfileModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    let userId: String
    let email: String
    let displayName: String
    let avatarURL: String?
    
}

