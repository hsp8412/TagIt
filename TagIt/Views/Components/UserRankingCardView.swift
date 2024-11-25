//
//  UserRankingCardView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

struct UserRankingCardView: View {
    let rank: Int
    let user: UserProfile
    let fontSize: CGFloat
    let highlight: Bool
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .frame(height: fontSize*2)
                .foregroundStyle(highlight ? .green.opacity(0.7) : .white)
                .shadow(radius: 5)
            
            HStack {
                // Rank
                Text("\(rank)")
                    .font(.system(size: fontSize+10, weight: .bold))
                    .foregroundStyle(.clear)
                    .padding(.horizontal)
                    .overlay(
                        LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom)
                            .mask(
                                Text("\(rank)")
                                    .font(.system(size: fontSize+10, weight: .bold))
                            )
                    )
                    
                // User profile
                UserAvatarView(avatarURL: user.avatarURL ?? "")
                    .frame(width: fontSize, height: fontSize)
                
                Text(user.displayName)
                    .font(.custom("Gill Sans", size: fontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .lineLimit(1)
                
                // Ranking Points
                Text("\(user.rankingPoints) pts")
                    .frame(width: 100, alignment: .trailing)
                    .font(.system(size: fontSize))
                    .foregroundStyle(.clear)
                    .overlay(
                        LinearGradient(colors: [.yellow, .green], startPoint: .top, endPoint: .bottom)
                            .mask(
                                Text("\(user.rankingPoints) pts")
                                    .font(.system(size: fontSize, weight: .bold))
                                    .frame(width: 100, alignment: .trailing)
                            )
                    )
                    .lineLimit(1)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


#Preview {
    UserRankingCardView(
        rank: 1,
        user: UserProfile(
            id: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2",
            email: "test1@example.com",
            displayName: "test1111111111111",
            avatarURL: "",
            score: 0,
            savedDeals: [],
            totalUpvotes: 50000000,
            totalDownvotes: 0,
            totalDeals: 0,
            totalComments: 0,
            rankingPoints: 50000000
        ),
        fontSize: 25,
        highlight: true
    )
}

