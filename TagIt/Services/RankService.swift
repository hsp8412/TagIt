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
     Fetches and sorts all users by ranking points.
     
     - Parameters:
        - completion: A closure that returns a `Result` containing a sorted array of `UserProfile` on success or an `Error` on failure.
     
     This function retrieves all users from Firestore, calculates their ranking points, and returns a sorted list of users in descending order of ranking points.
     */
    func fetchAndSortAllUsers(completion: @escaping (Result<[UserProfile], Error>) -> Void) {
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
                    let sortedUsers = usersWithUpdatedPoints.sorted { $0.rankingPoints > $1.rankingPoints }
                    completion(.success(sortedUsers))
                }
            case .failure(let error):
                print("Error fetching users: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /**
    Fetches the top-ranked users based on a given limit.

    - Parameters:
        - limit: The maximum number of top users to return.
        - completion: A closure that returns a `Result` containing an array of the top `UserProfile` objects on success or an `Error` on failure.

    This function retrieves all users, sorts them by ranking points, and extracts the top users based on the given limit.
    */
    func getTopUsers(limit: Int, completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        fetchAndSortAllUsers { result in
            switch result {
            case .success(let sortedUsers):
                let topUsers = Array(sortedUsers.prefix(limit))
                print("Top \(limit) users by ranking points:")
                topUsers.forEach { user in
                    print("\(user.displayName): \(user.rankingPoints) points")
                }
                completion(.success(topUsers))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    /**
    Fetches the rank of a specific user based on their ID.

    - Parameters:
        - userId: The ID of the user whose rank needs to be fetched.
        - completion: A closure that returns a `Result` containing the rank (as an `Int`) on success or an `Error` on failure.

    This function fetches all users, sorts them by ranking points, and determines the rank of the specified user.
    */
    func getUserRank(userId: String, completion: @escaping (Result<Int, Error>) -> Void) {
        fetchAndSortAllUsers { result in
            switch result {
            case .success(let sortedUsers):
                if let rank = sortedUsers.firstIndex(where: { $0.id == userId }) {
                    completion(.success(rank + 1))
                } else {
                    completion(.failure(NSError(domain: "RankService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found in the list."])))
                }
            case .failure(let error):
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
