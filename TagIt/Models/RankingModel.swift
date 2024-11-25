//
//  RankingWeights.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-21.
//

import Foundation

struct RankingWeights {
    static let defaultWeights = RankingWeights(dealWeight: 5, upvoteWeight: 1, commentWeight: 3)

    let dealWeight: Int
    let upvoteWeight: Int
    let commentWeight: Int
}


