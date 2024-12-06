//
//  DealRankingCardView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-18.
//

import SwiftUI

/**
 A view that displays a ranked deal card with information about the deal including the rank, product details, location, and a photo.
 It also navigates to the deal's detailed view when tapped.
 */
struct DealRankingCardView: View {
    // MARK: - Properties

    /// The rank of the deal.
    let rank: Int
    /// The deal to display in the card.
    let deal: Deal
    /// The font size used in the card for styling.
    let fontSize: CGFloat

    // MARK: - View Body

    var body: some View {
        NavigationLink(destination: DealDetailView(deal: deal)) {
            ZStack {
                // Background of the card
                RoundedRectangle(cornerRadius: 20)
                    .frame(height: fontSize * 7)
                    .foregroundStyle(.white)
                    .shadow(radius: 5) // Add shadow for visual depth

                HStack {
                    // Rank display with gradient
                    Text("\(rank)")
                        .font(.system(size: fontSize * 2, weight: .bold))
                        .foregroundStyle(.clear)
                        .padding(.horizontal)
                        .overlay(
                            LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom) // Gradient applied to rank text
                                .mask(
                                    Text("\(rank)")
                                        .font(.system(size: fontSize * 2, weight: .bold)) // Mask the gradient with rank text
                                )
                        )

                    // Deal information display
                    VStack(alignment: .leading) {
                        Text(deal.productText)
                            .font(.custom("Gill Sans", size: fontSize))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.leading)
                            .frame(height: fontSize * 4.5)
                            .padding(.leading, 5)
                            .lineLimit(3) // Limit product text to 3 lines

                        // Location display
                        HStack {
                            Image(systemName: "mappin")
                                .foregroundStyle(.green) // Green color for the location pin

                            Text(deal.location)
                                .font(.custom("Gill Sans", size: fontSize * 0.8))
                                .foregroundStyle(.green)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2) // Limit location text to 2 lines
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Expand to fill remaining space

                    // Deal photo display
                    AsyncImage(url: URL(string: deal.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100) // Image size
                                .cornerRadius(35) // Rounded corners for image
                        } else {
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .cornerRadius(25) // Default placeholder while loading image
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.trailing) // Right padding for layout
            }
        }
    }
}

#Preview {
    DealRankingCardView(
        rank: 1,
        deal: Deal(
            userID: "123",
            photoURL: "https://i.imgur.com/8ciNZcY.jpeg",
            productText: "Tropicana Orange Juice",
            postText: "",
            price: 1.23,
            location: "Safeway",
            date: "",
            commentIDs: [],
            upvote: 5,
            downvote: 6
        ),
        fontSize: 25
    )
}
