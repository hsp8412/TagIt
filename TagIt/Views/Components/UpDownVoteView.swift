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
        HStack(spacing: 10) { // Horizontal layout with reduced spacing
            // Upvote Button
            Button(action: {
                handleVote(voteType: .upvote)
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(upVoteTap ? .green : .gray) // Green when upvoted
                    Text("\(upVote)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .animation(.easeInOut(duration: 0.2), value: upVoteTap)
            }

            // Downvote Button
            Button(action: {
                handleVote(voteType: .downvote)
            }) {
                VStack(spacing: 5) {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(downVoteTap ? .red : .gray) // Red when downvoted
                    Text("\(downVote)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .animation(.easeInOut(duration: 0.2), value: downVoteTap)
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
        let isUndoingVote = (voteType == .upvote && upVoteTap) || (voteType == .downvote && downVoteTap)
        
        if isUndoingVote {
            VoteService.shared.removeVote(userId: userId, itemId: id, itemType: type) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        upVoteTap = false
                        downVoteTap = false
                        fetchUpdatedVotes()
                    case .failure(let error):
                        print("Error removing vote: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            VoteService.shared.handleVote(userId: userId, itemId: id, itemType: type, voteType: voteType) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
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
                    upVote = counts.upvotes
                    downVote = counts.downvotes
                    fetchUserVoteState()
                case .failure(let error):
                    print("Error fetching updated vote counts: \(error.localizedDescription)")
                }
            }
        }
    }
}
