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
    
    enum VoteType: String, Codable {
        case upvote
        case downvote
    }
}
