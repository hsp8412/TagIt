//
//  UserRankingCardView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-17.
//

import SwiftUI

/**
 A view that displays a user's ranking card, showing the rank, user avatar, display name, and ranking points.
 The background is highlighted based on the `highlight` flag, and the rank and points have gradient effects for emphasis.
 */
struct UserRankingCardView: View {
    // MARK: - Properties

    /// The rank of the user.
    let rank: Int
    /// The user profile to display.
    let user: UserProfile
    /// The font size for text and layout.
    let fontSize: CGFloat
    /// A flag indicating whether the card should be highlighted.
    let highlight: Bool

    // MARK: - View Body

    var body: some View {
        ZStack {
            // Background with conditional highlight color
            RoundedRectangle(cornerRadius: 20)
                .frame(height: fontSize * 2)
                .foregroundStyle(highlight ? .green.opacity(0.7) : .white) // Highlight based on flag
                .shadow(radius: 5)

            HStack {
                // Rank display with gradient
                Text("\(rank)")
                    .font(.system(size: fontSize + 10, weight: .bold))
                    .foregroundStyle(.clear)
                    .padding(.horizontal)
                    .overlay(
                        LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom) // Gradient for rank
                            .mask(
                                Text("\(rank)")
                                    .font(.system(size: fontSize + 10, weight: .bold))
                            )
                    )

                // User avatar
                UserAvatarView(avatarURL: user.avatarURL ?? "")
                    .frame(width: fontSize, height: fontSize)

                // User display name
                Text(user.displayName)
                    .font(.custom("Gill Sans", size: fontSize))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .lineLimit(1)

                // Ranking points display with gradient
                Text("\(user.rankingPoints) pts")
                    .frame(width: 100, alignment: .trailing)
                    .font(.system(size: fontSize))
                    .foregroundStyle(.clear)
                    .overlay(
                        LinearGradient(colors: [.yellow, .green], startPoint: .top, endPoint: .bottom) // Gradient for ranking points
                            .mask(
                                Text("\(user.rankingPoints) pts")
                                    .font(.system(size: fontSize, weight: .bold))
                                    .frame(width: 100, alignment: .trailing)
                            )
                    )
                    .lineLimit(1)
                    .padding(.trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Align all elements to the left
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
            totalUpvotes: 50_000_000,
            totalDownvotes: 0,
            totalDeals: 0,
            totalComments: 0,
            rankingPoints: 50_000_000
        ),
        fontSize: 25,
        highlight: true
    )
}
