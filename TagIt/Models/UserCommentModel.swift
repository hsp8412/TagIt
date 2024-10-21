//
//  UserCommentModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import Foundation
import FirebaseFirestore

struct UserComments: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var commentText: String
    
    // 0: Deals, 1: Barcode Item
    var type: Int
    var upvote: Int
    var downvote: Int
}
