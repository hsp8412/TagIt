//
//  SearchService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-18.
//

import FirebaseCore
import FirebaseFirestore
import Foundation
import Search

/**
 A service responsible for handling search functionalities within the TagIt application.

 This service integrates with Algolia for searching deals and interacts with Firestore to fetch
 the corresponding deal details based on search results.
 */
class SearchService {
    private let client: SearchClient
    private let indexName: String = "search_deals"

    init() {
        // First try to get credentials from Info.plist
        let credentials: (apiKey: String, appID: String)
        
        // We use multiple methods to fetch credentials to provide better error messages
        if let infoPlistPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let infoPlist = NSDictionary(contentsOfFile: infoPlistPath),
           let apiKey = infoPlist["ALGOLIA_API_KEY"] as? String,
           let appID = infoPlist["ALGOLIA_APP_ID"] as? String {
            credentials = (apiKey, appID)
        }
        // Fallback to reading from Bundle directly
        else if let apiKey = Bundle.main.object(forInfoDictionaryKey: "ALGOLIA_API_KEY") as? String,
                let appID = Bundle.main.object(forInfoDictionaryKey: "ALGOLIA_APP_ID") as? String {
            credentials = (apiKey, appID)
        }
        else {
            print("""
                ⚠️ Algolia configuration error:
                Could not find Algolia credentials in either Info.plist or Bundle.
                Please check:
                1. Config.xcconfig is properly linked in Build Settings
                2. Info.plist contains ALGOLIA_APP_ID and ALGOLIA_API_KEY entries
                3. The configuration files are included in the target
                Current Bundle Path: \(Bundle.main.bundlePath)
                """)
            fatalError("Missing Algolia configuration")
        }

        do {
            client = try SearchClient(appID: credentials.appID, apiKey: credentials.apiKey)
            print("✅ Algolia client initialized successfully with App ID: \(credentials.appID)")
        } catch {
            print("❌ Failed to initialize Algolia client: \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
    }

    /**
     Searches for deals based on a query string and retrieves the corresponding `Deal` objects from Firestore.

     - Parameter query: The search query string used to find matching deals in Algolia.
     - Throws: An error if the search operation fails or if fetching deals from Firestore encounters an issue.
     - Returns: An array of `Deal` objects that match the search query, sorted by their `dateTime` in descending order.

     This function performs a search using Algolia's search service, extracts the `objectID`s from the search hits,
     and then fetches the corresponding `Deal` documents from Firestore. The resulting deals are sorted by
     their `dateTime` in descending order.
     */
    func searchDeals(query: String) async throws -> [Deal] {
        let response: SearchResponses<DealHit> = try await client
            .search(searchMethodParams: SearchMethodParams(requests: [SearchQuery.searchForHits(SearchForHits(
                query: query,
                indexName: indexName
            ))]))
        //        print("Raw Algolia response: \(response)")

        // Step 1: Extract objectIDs from search hits
        let objectIDs = response.results.compactMap { result in
            switch result {
            case let .searchResponse(searchResponse):
                print(searchResponse.hits)
                return searchResponse.hits.map(\.objectID)
            case .searchForFacetValuesResponse:
                return []
            }
        }.flatMap(\.self) // Flatten nested arrays to a single [String]

        // Step 2: Fetch corresponding deals from the database
        return try await fetchDealsFromDatabase(objectIDs: objectIDs)
    }

    /**
     Fetches `Deal` objects from Firestore based on an array of `objectID`s.

     - Parameter objectIDs: An array of `String` representing the `objectID`s of the deals to be fetched.
     - Throws: An error if fetching any of the deals from Firestore fails.
     - Returns: An array of `Deal` objects corresponding to the provided `objectID`s, sorted by `dateTime` in descending order.

     This function performs concurrent fetch operations for each `objectID` using Swift's concurrency features.
     It collects all successfully fetched deals, sorts them by their `dateTime` in descending order, and returns the sorted array.
     */
    private func fetchDealsFromDatabase(objectIDs: [String]) async throws -> [Deal] {
        // Replace this with your actual database fetching logic

        let firestore = Firestore.firestore()

        let deals = try await withThrowingTaskGroup(of: Deal?.self) { group in
            for id in objectIDs {
                group.addTask {
                    let document = try await firestore.collection("Deals").document(id).getDocument()
                    var deal = try document.data(as: Deal.self)

                    // Extract and convert dateTime
                    if let timestamp = document.get("dateTime") as? Timestamp {
                        let dateString = Utils.timeAgoString(from: timestamp)
                        deal.date = dateString // Save the formatted string to the `date` field
                    }

                    return deal
                }
            }

            return try await group.reduce(into: [Deal]()) { result, deal in
                if let deal {
                    result.append(deal)
                }
            }
        }

        // Sort deals by dateTime in descending order (newest first)
        let sortedDeals = deals.sorted { firstDeal, secondDeal in
            guard let firstTimestamp = firstDeal.dateTime?.seconds,
                  let secondTimestamp = secondDeal.dateTime?.seconds
            else {
                return false // Treat as unordered if dateTime is missing
            }
            return firstTimestamp > secondTimestamp // Descending order
        }

        return sortedDeals
    }
}
