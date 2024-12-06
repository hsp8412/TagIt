//
//  UserRankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

/**
 A view that displays the ranking of top users along with the current user's rank. It fetches the top 20 users' rankings and shows them in a scrollable list.
 The current user's rank and profile are highlighted, and there is a refreshable list for fetching updated rankings.
 */
struct UserRankingView: View {
    // MARK: - Properties

    /// List of top users to display.
    @State private var topUsers: [UserProfile] = []
    /// Current user's profile information.
    @State private var currentUser: UserProfile?
    /// Current user's rank.
    @State private var currentUserRank: Int?
    /// Loading state for ranking data.
    @State private var isLoading: Bool = true
    /// Error message to display in case of failure.
    @State private var errorMessage: String?

    // MARK: - View Body

    var body: some View {
        VStack {
            // Title with gradient effect
            HStack {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .padding(.horizontal, 5)

                Text("User Ranking")
                    .font(.system(size: 30, weight: .bold))
            }
            .overlay(
                LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom) // Gradient overlay on title
                    .mask(
                        HStack {
                            Image(systemName: "trophy.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                                .padding(.horizontal, 5)

                            Text("User Ranking")
                                .font(.system(size: 30, weight: .bold))
                        }
                    )
            )
            .offset(y: 20)

            // Loading and Error Handling
            if isLoading {
                ProgressView("Loading user ranking...")
                    .frame(maxHeight: .infinity, alignment: .center)
            } else if let errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                // Scrollable list of top users
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(topUsers.indices, id: \.self) { index in
                            let user = topUsers[index]
                            UserRankingCardView(rank: index + 1, user: user, fontSize: 25, highlight: (index + 1) == currentUserRank)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
                .refreshable {
                    fetchRanking() // Pull-to-refresh to fetch updated rankings
                }

                // Current user's ranking display
                VStack {
                    Text("Your Rank")
                        .font(.title2)
                        .bold()
                        .padding()

                    if let user = currentUser, let rank = currentUserRank {
                        UserRankingCardView(rank: rank, user: user, fontSize: 25, highlight: true)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            fetchRanking() // Fetch user rankings on view appear
        }
    }

    // MARK: - Helper Functions

    /**
     Fetches the top users and the current user's rank.
     */
    func fetchRanking() {
        let limit = 20
        print("Fetching top users for User Ranking View...")

        // Fetch top users
        RankService.shared.getTopUsers(limit: limit) { result in
            switch result {
            case let .success(topUsers):
                print("Fetched \(topUsers.count) top users.")
                self.topUsers = topUsers

                // Fetch current user rank
                if let currentUserId = AuthService.shared.getCurrentUserID() {
                    RankService.shared.getUserRank(userId: currentUserId) { rankResult in
                        switch rankResult {
                        case let .success(rank):
                            currentUserRank = rank
                            AuthService.shared.getCurrentUser { result in
                                currentUser = result
                            }

                            if let currentUser {
                                print("Current user: \(currentUser.displayName), Rank: \(rank), Points: \(currentUser.rankingPoints)")
                            } else {
                                print("Current user not found in top users.")
                            }
                        case let .failure(error):
                            print("Error fetching user rank: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                } else {
                    print("Current user ID not found.")
                    isLoading = false
                }

            case let .failure(error):
                print("Error fetching top users: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    UserRankingView()
}
