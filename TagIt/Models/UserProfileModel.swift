//
//  UserProfileModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var displayName: String
    var avatarURL: String
}

func findUserByID (id: String) -> User? {
    // Stub
    let users = [
        User(id: "UID1", email: "1@gmail.com", displayName: "1 Username", avatarURL: "https://i.imgur.com/0yHrbpq.jpeg"),
        User(id: "UID2", email: "2@gmail.com", displayName: "2 Username", avatarURL: "https://i.imgur.com/0yHrbpq.jpeg")
    ]

    return users.first {$0.id == id}
}
