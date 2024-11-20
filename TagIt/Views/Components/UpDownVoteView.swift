//
//  UpDownVoteView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-31.
//

import SwiftUI
struct UpDownVoteView: View {
    let userId: String
    let type: Vote.ItemType
    let id: String
    @Binding var upVote: Int
    @Binding var downVote: Int
    @State var upVoteTap: Bool = false
    @State var downVoteTap: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                handleVote(voteType: .upvote)
            }) {
                ZStack {
                    if upVoteTap {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .frame(width: 100, height: 30)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                            .frame(width: 100, height: 30)
                    }
                    
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundStyle(upVoteTap ? .white : .green)
                        Text("\(upVote)")
                            .foregroundColor(upVoteTap ? .white : .green)
                            .padding(.horizontal)
                    }
                }
            }
            
            Button(action: {
                handleVote(voteType: .downvote)
            }) {
                ZStack {
                    if downVoteTap {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red)
                            .frame(width: 100, height: 30)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: 100, height: 30)
                    }
                    
                    HStack {
                        Image(systemName: "hand.thumbsdown.fill")
                            .foregroundStyle(downVoteTap ? .white : .red)
                        Text("\(downVote)")
                            .foregroundColor(downVoteTap ? .white : .red)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            fetchUserVoteState()
        }
    }
    
    private func fetchUserVoteState() {
        VoteService.shared.getUserVote(userId: userId, itemId: id, itemType: type) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let vote):
                    if let vote = vote {
                        upVoteTap = (vote.voteType == .upvote)
                        downVoteTap = (vote.voteType == .downvote)
                    } else {
                        upVoteTap = false
                        downVoteTap = false
                    }
                case .failure(let error):
                    print("Error fetching vote: \(error.localizedDescription)")
                }
            }
        }
    }

    
    private func handleVote(voteType: Vote.VoteType) {
        // Determine if the user is undoing their current vote
        let isUndoingVote = (voteType == .upvote && upVoteTap) || (voteType == .downvote && downVoteTap)
        
        if isUndoingVote {
            // Undo the vote
            VoteService.shared.removeVote(userId: userId, itemId: id, itemType: type) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Vote removed successfully")
                        // Reset highlight states
                        upVoteTap = false
                        downVoteTap = false
                        fetchUpdatedVotes()
                    case .failure(let error):
                        print("Error removing vote: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Cast or change the vote
            VoteService.shared.handleVote(userId: userId, itemId: id, itemType: type, voteType: voteType) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Vote successfully updated for \(voteType.rawValue)")
                        // Update highlight states
                        upVoteTap = (voteType == .upvote)
                        downVoteTap = (voteType == .downvote)
                        fetchUpdatedVotes()
                    case .failure(let error):
                        print("Error updating vote: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    
    private func fetchUpdatedVotes() {
        VoteService.shared.getVoteCounts(itemId: id, itemType: type) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let counts):
                    print("Fetched updated vote counts: \(counts.upvotes) upvotes, \(counts.downvotes) downvotes")
                    upVote = counts.upvotes
                    downVote = counts.downvotes
                    
                    // Optionally synchronize tap states
                    fetchUserVoteState() // Ensure highlight states are in sync
                case .failure(let error):
                    print("Error fetching updated vote counts: \(error.localizedDescription)")
                }
            }
        }
    }
}
