//
//  RankService.swift
//  TagIt
//
//  Created by Peter Tran on 2024-11-21.
//

import Foundation

class RankService {
    // Singleton instance
    static let shared = RankService()

    // Private initializer to prevent creating multiple instances
    private init() {}

    // Ranking weights used for calculation
    private let rankingWeights = RankingWeights.defaultWeights

    /**
     Fetches and calculates the top-ranked users.
     
     - Parameters:
        - limit: The maximum number of users to return.
        - completion: A closure that returns a `Result` containing an array of `UserProfile` on success or an `Error` on failure.
     */
    func fetchTopUsers(limit: Int, completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        FirestoreService.shared.readCollection(
            collectionName: FirestoreCollections.user,
            modelType: UserProfile.self
        ) { result in
            switch result {
            case .success(let users):
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
                    // Sort by rankingPoints and limit the number of users
                    let sortedUsers = usersWithUpdatedPoints.sorted { $0.rankingPoints > $1.rankingPoints }
                    let topUsers = Array(sortedUsers.prefix(limit))
                    
                    print("Top \(limit) users by ranking points:")
                    topUsers.forEach { user in
                        print("\(user.displayName): \(user.rankingPoints) points")
                    }

                    completion(.success(topUsers))
                }
            case .failure(let error):
                print("Error fetching users: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }


    /**
     Updates the ranking points for a specific user in Firestore.
     
     - Parameters:
        - userId: The ID of the user to update.
        - completion: A closure that returns an `Error?` indicating success or failure.
     */
    func updateRankingPoints(for userId: String, completion: @escaping (Error?) -> Void) {
        FirestoreService.shared.readDocument(
            collectionName: FirestoreCollections.user,
            documentID: userId,
            modelType: UserProfile.self
        ) { result in
            switch result {
            case .success(let user):
                self.calculateRankingPoints(for: user) { newRankingPoints in
                    FirestoreService.shared.updateField(
                        collectionName: FirestoreCollections.user,
                        documentID: userId,
                        field: "rankingPoints",
                        value: newRankingPoints
                    ) { error in
                        if let error = error {
                            print("[DEBUG] Error updating ranking points for user \(userId): \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("[DEBUG] Successfully updated ranking points for user \(userId) to \(newRankingPoints).")
                            completion(nil)
                        }
                    }
                }
            case .failure(let error):
                print("[DEBUG] Error fetching user for ranking points update: \(error.localizedDescription)")
                completion(error)
            }
        }
    }

    /**
     Calculates ranking points for a given user based on weights and user activity, comments from deals are limited to 1
     
     - Parameter user: The `UserProfile` for which to calculate ranking points.
     - Returns: The calculated ranking points.
     */
    func calculateRankingPoints(for user: UserProfile, completion: @escaping (Int) -> Void) {
        CommentService.shared.getUniqueDealsCommentedByUser(userID: user.id) { result in
            switch result {
            case .success(let uniqueDeals):
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
            case .failure(let error):
                print("[DEBUG] Error calculating ranking points for user \(user.id): \(error.localizedDescription)")
                completion(0)
            }
        }
    }

}
