//
//  RankService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-21.
//

import Foundation

/**
 A service responsible for managing user rankings.

 This service provides functionalities to fetch and sort users based on their ranking points,
 retrieve top-ranked users, determine a user's rank, and update ranking points in Firestore.
 */
class RankService {
    /**
     The shared singleton instance of `RankService`.

     This ensures that a single, consistent instance of the service is used throughout the application.
     */
    static let shared = RankService()

    /**
     Private initializer to enforce the singleton pattern.
     */
    private init() {}

    /**
     The ranking weights used for calculating user ranking points.

     These weights determine how different user activities contribute to their overall ranking.
     */
    private let rankingWeights = RankingWeights.defaultWeights

    /**
     Fetches and sorts all users by their ranking points.

     - Parameter completion: A closure that receives a `Result` containing a sorted array of `UserProfile` on success or an `Error` on failure.

     This function retrieves all users from Firestore, calculates their ranking points, and returns a sorted list of users in descending order of ranking points.
     */
    func fetchAndSortAllUsers(completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        FirestoreService.shared.readCollection(
            collectionName: FirestoreCollections.user,
            modelType: UserProfile.self
        ) { result in
            switch result {
            case let .success(users):
                print("Fetched \(users.count) users from Firestore.")

                var usersWithUpdatedPoints: [UserProfile] = []
                let group = DispatchGroup()

                for user in users {
                    group.enter()
                    self.calculateRankingPoints(for: user) { points in
                        var updatedUser = user
                        updatedUser.rankingPoints = points
                        usersWithUpdatedPoints.append(updatedUser)
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    let sortedUsers = usersWithUpdatedPoints.sorted { $0.rankingPoints > $1.rankingPoints }
                    completion(.success(sortedUsers))
                }
            case let .failure(error):
                print("Error fetching users: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /**
     Fetches the top-ranked users based on a specified limit.

     - Parameters:
       - limit: The maximum number of top users to return.
       - completion: A closure that receives a `Result` containing an array of the top `UserProfile` objects on success or an `Error` on failure.

     This function retrieves all users, sorts them by ranking points, and extracts the top users based on the given limit.
     */
    func getTopUsers(limit: Int, completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        fetchAndSortAllUsers { result in
            switch result {
            case let .success(sortedUsers):
                let topUsers = Array(sortedUsers.prefix(limit))
                print("Top \(limit) users by ranking points:")
                for user in topUsers {
                    print("\(user.displayName): \(user.rankingPoints) points")
                }
                completion(.success(topUsers))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     Fetches the rank of a specific user based on their ID.

     - Parameters:
       - userId: The ID of the user whose rank needs to be fetched.
       - completion: A closure that receives a `Result` containing the rank (as an `Int`) on success or an `Error` on failure.

     This function fetches all users, sorts them by ranking points, and determines the rank of the specified user.
     */
    func getUserRank(userId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        fetchAndSortAllUsers { result in
            switch result {
            case let .success(sortedUsers):
                if let rank = sortedUsers.firstIndex(where: { $0.id == userId }) {
                    completion(.success(rank + 1))
                } else {
                    completion(.failure(NSError(domain: "RankService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found in the list."])))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     Updates the ranking points for a specific user in Firestore.

     - Parameters:
       - userId: The ID of the user to update.
       - completion: A closure that returns an `Error?` indicating success or failure.

     This function fetches the user's profile, recalculates their ranking points, and updates the `rankingPoints` field in Firestore.
     */
    func updateRankingPoints(for userId: String, completion: @escaping (Error?) -> Void) {
        FirestoreService.shared.readDocument(
            collectionName: FirestoreCollections.user,
            documentID: userId,
            modelType: UserProfile.self
        ) { result in
            switch result {
            case let .success(user):
                self.calculateRankingPoints(for: user) { newRankingPoints in
                    FirestoreService.shared.updateField(
                        collectionName: FirestoreCollections.user,
                        documentID: userId,
                        field: "rankingPoints",
                        value: newRankingPoints
                    ) { error in
                        if let error {
                            print("[DEBUG] Error updating ranking points for user \(userId): \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("[DEBUG] Successfully updated ranking points for user \(userId) to \(newRankingPoints).")
                            completion(nil)
                        }
                    }
                }
            case let .failure(error):
                print("[DEBUG] Error fetching user for ranking points update: \(error.localizedDescription)")
                completion(error)
            }
        }
    }

    /**
     Calculates ranking points for a given user based on predefined weights and user activities.

     - Parameters:
       - user: The `UserProfile` for which to calculate ranking points.
       - completion: A closure that receives the calculated ranking points as an `Int`.

     This function considers the number of deals, upvotes, and unique comments by the user to compute their total ranking points.
     */
    func calculateRankingPoints(for user: UserProfile, completion: @escaping (Int) -> Void) {
        CommentService.shared.getUniqueDealsCommentedByUser(userID: user.id) { result in
            switch result {
            case let .success(uniqueDeals):
                let weights = RankingWeights.defaultWeights
                let pointsFromDeals = user.totalDeals * weights.dealWeight
                let pointsFromUpvotes = user.totalUpvotes * weights.upvoteWeight
                let pointsFromComments = uniqueDeals.count * weights.commentWeight

                let totalPoints = pointsFromDeals + pointsFromUpvotes + pointsFromComments
                print("User \(user.displayName) Ranking Points:")
                print(" - Deals: \(pointsFromDeals)")
                print(" - Upvotes: \(pointsFromUpvotes)")
                print(" - Comments (limited to 1 per deal): \(pointsFromComments)")
                print(" - Total: \(totalPoints)")
                completion(totalPoints)
            case let .failure(error):
                print("[DEBUG] Error calculating ranking points for user \(user.id): \(error.localizedDescription)")
                completion(0)
            }
        }
    }
}
