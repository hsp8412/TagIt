//
//  DealRankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-18.
//

import SwiftUI

/**
 A view that displays a ranked list of deals based on the difference between upvotes and downvotes.
 The view fetches the top deals, sorts them by ranking, and displays them in a scrollable list.
 */
struct DealRankingView: View {
    // MARK: - Properties

    /// List of top deals to display.
    @State private var topDeals: [Deal] = []
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

                Text("Deal Ranking")
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

                            Text("Deal Ranking")
                                .font(.system(size: 30, weight: .bold))
                        }
                    )
            )
            .offset(y: 20)

            // Loading and Error Handling
            if isLoading {
                ProgressView("Loading deal ranking...")
                    .frame(maxHeight: .infinity, alignment: .center)
            } else if let errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                // Scrollable list of top deals
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(topDeals.indices, id: \.self) { index in
                            let deal = topDeals[index]
                            DealRankingCardView(rank: index + 1, deal: deal, fontSize: 25)
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
            }
        }
        .onAppear {
            fetchRanking() // Fetch deals on view appear
        }
    }

    // MARK: - Helper Functions

    /**
     Fetches the list of deals, sorts them by upvote-downvote difference, and updates the ranking.
     */
    func fetchRanking() {
        DealService.shared.getDeals { result in
            switch result {
            case let .success(fetchedDeals):
                // Sort deals based on the difference between upvotes and downvotes
                topDeals = fetchedDeals.sorted { ($0.upvote - $0.downvote) > ($1.upvote - $1.downvote) }
                isLoading = false
            case let .failure(error):
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    DealRankingView()
}
