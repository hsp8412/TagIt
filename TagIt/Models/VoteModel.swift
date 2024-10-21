//
//  VoteModel.swift
//  TagIt
//
//  Created by Peter Tran on 2024-10-20.
//

import Foundation

struct Vote: Codable {
    let voteId: String
    let userId: String
    let itemId: String
    let voteType: VoteType
    let itemType: ItemType

    enum VoteType: String, Codable {
        case upvote
        case downvote
    }
    
    enum ItemType: Int, Codable {
        case comment = 0
        case deal = 1
        case review = 2
    }
}
