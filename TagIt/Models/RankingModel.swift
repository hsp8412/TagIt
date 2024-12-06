//
//  RankingModel.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-21.
//

import Foundation

/**
 Represents the weights used for calculating user ranking points.

 This struct defines the importance of different user activities such as posting deals, receiving upvotes, and making comments on deals.
 These weights are used to compute a user's total ranking points, which determine their rank within the application.
 */
struct RankingWeights {
    /**
     The default set of ranking weights.

     - `dealWeight`: The weight assigned to each deal posted by the user.
     - `upvoteWeight`: The weight assigned to each upvote received by the user's deals.
     - `commentWeight`: The weight assigned to each comment made on the user's deals.

     **Default Values:**
     - `dealWeight`: 5
     - `upvoteWeight`: 1
     - `commentWeight`: 3
     */
    static let defaultWeights = RankingWeights(dealWeight: 5, upvoteWeight: 1, commentWeight: 3)

    /**
     The weight assigned to each deal posted by the user.

     Higher values increase the impact of deal postings on the user's ranking points.

     **Default Value:** 5
     */
    let dealWeight: Int

    /**
     The weight assigned to each upvote received by the user's deals.

     Higher values increase the impact of upvotes on the user's ranking points.

     **Default Value:** 1
     */
    let upvoteWeight: Int

    /**
     The weight assigned to each comment made on the user's deals.

     Higher values increase the impact of comments on the user's ranking points.

     **Default Value:** 3
     */
    let commentWeight: Int
}
