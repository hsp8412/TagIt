//
//  DealRankingView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-18.
//

import SwiftUI

struct DealRankingView: View {
    @State private var topDeals: [Deal] = []
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
                
                Text("Deal Ranking")
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
                            
                            Text("Deal Ranking")
                                .font(.system(size: 30, weight: .bold))
                        }
                    )
            )
            .offset(y: 20)
            
            // Deals
            if (isLoading) {
                ProgressView("Loading deal ranking...")
                    .frame(maxHeight: .infinity, alignment: .center)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            } else {
                // Ranking cards
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(topDeals.indices, id: \.self) { index in
                            let deal = topDeals[index]
                            DealRankingCardView(rank: index+1, deal: deal, fontSize: 25)
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
            }
        }
        .onAppear() {
            fetchRanking()
        }
    }
    
    // Sorted by upVote - downVote
    func fetchRanking() {
        DealService.shared.getDeals { result in
            switch result {
            case .success(let fetchedDeals):
                topDeals = fetchedDeals.sorted { ($0.upvote - $0.downvote) > ($1.upvote - $1.downvote)}
                self.isLoading = false
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    DealRankingView()
}
