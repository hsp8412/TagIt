//
//  UserProfileModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-16.
//

import FirebaseFirestore
import Foundation

/**
 Represents a user's profile.

 This struct encapsulates all relevant information about a user, including their identity, engagement metrics, and preferences.
 It conforms to `Identifiable` and `Codable` protocols to facilitate easy integration with SwiftUI views and Firestore database operations.
 */
struct UserProfile: Identifiable, Codable {
    /// The unique identifier for the user.
    var id: String

    /// The user's email address.
    var email: String

    /// The display name chosen by the user.
    var displayName: String

    /// The URL of the user's avatar image. Optional if the user hasn't set an avatar.
    var avatarURL: String?

    /// The user's current score in the application.
    var score: Int

    /// An array of deal IDs that the user has saved.
    var savedDeals: [String]

    /// The total number of upvotes the user has received across their deals and comments.
    var totalUpvotes: Int

    /// The total number of downvotes the user has received across their deals and comments.
    var totalDownvotes: Int

    /// The total number of deals the user has posted. Defaults to `0`.
    var totalDeals: Int = 0

    /// The total number of comments the user has made. Defaults to `0`.
    var totalComments: Int = 0

    /// The total ranking points accumulated by the user based on their activities. Defaults to `0`.
    var rankingPoints: Int = 0
}
