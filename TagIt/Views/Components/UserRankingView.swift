//
//  UserRankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

// This hopefully will be the updated UserProfile struct to store score?
struct UserProfile_Score: Identifiable, Codable {
    var id: String?
    var email: String
    var displayName: String
    var avatarURL: String?
    var score: Int
}

struct UserRankingView: View {
    @State private var topUsers: [UserProfile_Score] = []
    @State private var currentUser: UserProfile_Score?
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
                // Ranking cards
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
                    // Refresh the deal list
                    fetchRanking()
                }
                
                // ...
                VStack {
                    HStack(spacing: 20) {
                        Circle()
                            .fill(.gray.opacity(0.6))
                            .frame(width: 15)
                        
                        Circle()
                            .fill(.gray.opacity(0.6))
                            .frame(width: 15)
                        
                        Circle()
                            .fill(.gray.opacity(0.6))
                            .frame(width: 15)
                    }
                    
                    // Current user
                    UserRankingCardView(rank: currentUserRank ?? 0, user: currentUser!, fontSize: 30, highlight: false)
                        .padding()
                }
                .frame(height: 150)
            }
        }
        .onAppear() {
            fetchRanking()
        }
    }
    
    func fetchRanking() {
        // Dummy data
        // Get all user profiles
        let all_users: [UserProfile_Score] = [
            UserProfile_Score(id: "123", email: "abc@abc.com", displayName: "Test1", avatarURL: "", score: 150),
            UserProfile_Score(id: "456", email: "def@abc.com", displayName: "Test2222222", avatarURL: "", score: 20000),
            UserProfile_Score(id: "789", email: "ghi@abc.com", displayName: "Test31111111111", avatarURL: "", score: 100),
            UserProfile_Score(id: "111", email: "def@abc.com", displayName: "Test4", avatarURL: "", score: 300),
            UserProfile_Score(id: "222", email: "def@abc.com", displayName: "Test5", avatarURL: "", score: 80),
            UserProfile_Score(id: "333", email: "def@abc.com", displayName: "Test6", avatarURL: "", score: 70),
            UserProfile_Score(id: "444", email: "def@abc.com", displayName: "Test7", avatarURL: "", score: 60)
        ]
        
        // Sorted by score
        topUsers = all_users.sorted { $0.score > $1.score }
        
        // Get current user profile
        currentUser = UserProfile_Score(id: "789", email: "ghi@abc.com", displayName: "Test31111111111", avatarURL: "", score: 100)
        
        // Get current user rank
        currentUserRank = (topUsers.firstIndex(where: { $0.id == currentUser?.id}) ?? 0) + 1
        
        isLoading = false
    }
}

#Preview {
    UserRankingView()
}
