//
//  UpDownVoteView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-31.
//

import SwiftUI

struct UpDownVoteView: View {
    let type: Vote.ItemType
    let id: String
    let userId: String
    @State var upVote Int
    @State var downVote: Int
    // @State var showUpVote: Int
    // @State var showDownVote: Int
    @State var upVoteTap: Bool
    @State var downVoteTap: Bool
    
    init(type: Vote.ItemType, itemId: String, userId: String, upVote: Int, downVote: Int) {
        self.type = type
        self.itemId = itemId
        self.upVote = upVote
        self.downVote = downVote
        self.userId = userId
        // self.showUpVote = upVote
        // self.showDownVote = downVote

        if (VoteService.getUserVote(userId: userId, itemId: itemId, itemType: type) != `nil`){
            if (VoteService.getUserVote(userId: userId, itemId: itemId, itemType: type).voteType == "upvote"){
                self.upVoteTap = true
                self.downVoteTap = false
            }
            if (VoteService.getUserVote(userId: userId, itemId: itemId, itemType: type).voteType == "downvote"){
                self.upVoteTap = false
                self.downVoteTap = true
            }
            else{
                print("get user vote with no upvote or down vote")
            }
        }
        else{
            self.upVoteTap = false
            self.downVoteTap = false
        }
        
    }

    var body: some View {
        HStack {
            Button(action: {
                print("Thumbsup Tapped")

                handleVote(type: .upvote)
                
                upVoteTap.toggle()
            }) {
                ZStack {
                    if (upVoteTap) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .frame(width: 100, height: 30)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                            .frame(width: 100, height: 30)
                    }
                    
                    HStack {
                        if (upVoteTap) {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundStyle(Color.white)
                            
                            Text("\(upVote)")
                                .padding(.horizontal)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundStyle(Color.green)
                            
                            Text("\(upVote)")
                                .padding(.horizontal)
                                .foregroundColor(.green)
                        }
                    }
                    
                }
            }
            
            Button(action: {
                print("Thumbsdown Tapped")

                handleVote(type: .downvote)

                downVoteTap.toggle()
            }) {
                ZStack {
                    if (downVoteTap) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red)
                            .frame(width: 100, height: 30)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: 100, height: 30)
                    }
                    
                    HStack {
                        if (downVoteTap) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .foregroundStyle(Color.white)
                            
                            Text("\(downVote)")
                                .padding(.horizontal)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "hand.thumbsdown.fill")
                                .foregroundStyle(Color.red)
                            
                            Text("\(downVote)")
                                .padding(.horizontal)
                                .foregroundColor(.red)
                        }
                    }
                    
                }
            }
        }
    }

    private func handleVote(voteType: Vote.VoteType) {
        let voteService = VoteService.shared
        
        voteService.handleVote(userId: "currentUserId", itemId: id, itemType: type, voteType: voteType) { result in
            switch result {
            case .success:
                if voteType == .upvote {
                    if (upVoteTap){
                        upVoteTap = false
                        upVote -= 1
                    }                    
                    else if (downVoteTap) {
                        downVoteTap = false
                        upVoteTap = true
                        downVote -= 1
                        upVote += 1
                    }
                    else{
                        upVoteTap = true
                        upVote += 1
                    }

                } else {
                    if (downVoteTap){
                        downVoteTap = false
                        downVote -= 1
                    }                    
                    else if (upVoteTap) {
                        upVoteTap = false
                        downVoteTap = true
                        downVote += 1
                        upVote -= 1
                    }
                    else{
                        downVote = true
                        downVote += 1
                    }
                }
            case .failure(let error):
                print("Error voting: \(error.localizedDescription)")
            }
        }
    }
}

