//
//  UpDownVoteView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-31.
//

import FirebaseFirestore
import SwiftUI

/**
 A view that allows users to upvote or downvote an item (e.g., deal, product) and updates the vote counts accordingly.
 It also reflects the user's vote state (upvoted, downvoted, or none).
 */
struct UpDownVoteView: View {
    // MARK: - Properties

    /// The ID of the user who is voting.
    let userId: String
    /// The type of item being voted on (e.g., deal, product).
    let type: Vote.ItemType
    /// The ID of the item being voted on.
    let id: String
    /// Binding for the upvote count.
    @Binding var upVote: Int
    /// Binding for the downvote count.
    @Binding var downVote: Int
    /// State tracking whether the upvote button has been tapped.
    @State var upVoteTap: Bool = false
    /// State tracking whether the downvote button has been tapped.
    @State var downVoteTap: Bool = false

    // MARK: - View Body

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

    // MARK: - Helper Functions

    /**
     Fetches the current vote state for the user (upvoted, downvoted, or none).
     */
    private func fetchUserVoteState() {
        VoteService.shared.getUserVote(userId: userId, itemId: id, itemType: type) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(vote):
                    if let vote {
                        upVoteTap = (vote.voteType == .upvote)
                        downVoteTap = (vote.voteType == .downvote)
                    } else {
                        upVoteTap = false
                        downVoteTap = false
                    }
                case let .failure(error):
                    print("Error fetching vote: \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     Handles the vote action (upvote or downvote). It checks if the user is undoing their previous vote and updates the vote state accordingly.

     - Parameter voteType: The type of vote (upvote or downvote).
     */
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
                    case let .failure(error):
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
                    case let .failure(error):
                        print("Error updating vote: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    /**
     Fetches the updated vote counts and updates the UI accordingly.
     */
    private func fetchUpdatedVotes() {
        VoteService.shared.getVoteCounts(itemId: id, itemType: type) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(counts):
                    upVote = counts.upvotes
                    downVote = counts.downvotes
                    let dealId = id
                    DealService.shared.getDealById(id: dealId) { result in
                        switch result {
                        case var .success(deal):
                            deal.upvote = upVote
                            deal.downvote = downVote
                            updateDealInFirestore(deal)

                        case let .failure(error):
                            print("Error fetching deal: \(error.localizedDescription)")
                        }
                    }

                    fetchUserVoteState()
                case let .failure(error):
                    print("Error fetching updated vote counts: \(error.localizedDescription)")
                }
            }
        }
    }

    /**
     Updates the deal's vote counts in Firestore after a vote is submitted.

     - Parameter deal: The updated deal object with new vote counts.
     */
    private func updateDealInFirestore(_ deal: Deal) {
        guard let dealId = deal.id else { return }

        let dealRef = Firestore.firestore().collection(FirestoreCollections.deals).document(dealId)

        dealRef.updateData([
            "upvote": deal.upvote,
            "downvote": deal.downvote,
        ]) { error in
            if let error {
                print("Error updating deal in Firestore: \(error.localizedDescription)")
            } else {
                print("Successfully updated deal votes in Firestore.")
            }
        }
    }
}

#Preview {
    @Previewable @State var upVote = 5
    @Previewable @State var downVote = 6
    UpDownVoteView(userId: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", type: .deal, id: "1A3584D9-DF4E-4352-84F1-FA6812AE0A26", upVote: $upVote, downVote: $downVote)
}
