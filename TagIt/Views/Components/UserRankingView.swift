//
//  UserRankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI
struct UserRankingView: View {
    @State private var topUsers: [UserProfile] = []
    @State private var currentUser: UserProfile?
    @State private var currentUserRank: Int?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            // Title
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
                LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
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
            
            if (isLoading) {
                ProgressView("Loading user ranking...")
                    .frame(maxHeight: .infinity, alignment: .center)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(topUsers.indices, id: \.self) { index in
                            let user = topUsers[index]
                            UserRankingCardView(rank: index+1, user: user, fontSize: 25, highlight: (index+1) == currentUserRank)
                                .padding(.horizontal)
                                .padding(.top)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding()
                .refreshable {
                    fetchRanking()
                }
                
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
        .onAppear() {
            fetchRanking()
        }
    }

    func fetchRanking(limit: Int) {
        print("Fetching top users for User Ranking View...")

        // Fetch top users
        RankService.shared.getTopUsers(limit: limit) { result in
            switch result {
            case .success(let topUsers):
                print("Fetched \(topUsers.count) top users.")
                self.topUsers = topUsers

                // Fetch current user rank
                if let currentUserId = AuthService.shared.getCursrentUserID() {
                    RankService.shared.getUserRank(userId: currentUserId) { rankResult in
                        switch rankResult {
                        case .success(let rank):
                            self.currentUserRank = rank
                            self.currentUser = AuthService.shared.getCurrentUser()
                            
                            if let currentUser = self.currentUser {
                                print("Current user: \(currentUser.displayName), Rank: \(rank), Points: \(currentUser.rankingPoints)")
                            } else {
                                print("Current user not found in top users.")
                            }
                        case .failure(let error):
                            print("Error fetching user rank: \(error.localizedDescription)")
                            self.errorMessage = error.localizedDescription
                        }
                        self.isLoading = false
                    }
                } else {
                    print("Current user ID not found.")
                    self.isLoading = false
                }

            case .failure(let error):
                print("Error fetching top users: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }


}

#Preview {
    UserRankingView()
}
