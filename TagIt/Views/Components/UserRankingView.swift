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
    
    func fetchRanking() {
        print("Fetching top users for User Ranking View...")
        RankService.shared.fetchTopUsers(limit: 20) { result in
            switch result {
            case .success(let fetchedUsers):
                print("Fetched \(fetchedUsers.count) users for ranking.")
                self.topUsers = fetchedUsers
                if let currentUserId = AuthService.shared.getCurrentUserID() {
                    self.currentUser = fetchedUsers.first { $0.id == currentUserId }
                    self.currentUserRank = (self.topUsers.firstIndex(where: { $0.id == self.currentUser?.id }) ?? -1) + 1
                    if let currentUser = self.currentUser {
                        print("Current user: \(currentUser.displayName), Rank: \(self.currentUserRank ?? 0), Points: \(currentUser.rankingPoints)")
                    } else {
                        print("Current user not found in top users.")
                    }
                }
                self.isLoading = false
            case .failure(let error):
                print("Error fetching user ranking: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

}

#Preview {
    UserRankingView()
}
