//
//  SearchService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-18.
//

import Foundation
import Search
import FirebaseCore
import FirebaseFirestore

class SearchService {
    private let client: SearchClient
    private let indexName: String = "search_deals"
    
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ALGOLIA_API_KEY") as? String,
              let appID = Bundle.main.object(forInfoDictionaryKey: "ALGOLIA_APP_ID") as? String else {
            fatalError("Missing Algolia credentials in AppConfig.xcconfig")
        }
        
        do {
            self.client = try SearchClient(appID: appID, apiKey: apiKey)
        } catch {
            fatalError("Failed to initialize SearchClient: \(error)")
        }
    }
    
    func searchDeals(query: String) async throws -> [Deal] {
        
        let response: SearchResponses<DealHit> = try await client
            .search(searchMethodParams: SearchMethodParams(requests: [SearchQuery.searchForHits(SearchForHits(
                query: query,
                indexName: self.indexName
            ))]))
        //        print("Raw Algolia response: \(response)")
        
        // Step 1: Extract objectIDs from search hits
        let objectIDs = response.results.compactMap { result in
            switch result {
            case .searchResponse(let searchResponse):
                print(searchResponse.hits)
                return searchResponse.hits.map { $0.objectID }
            case .searchForFacetValuesResponse:
                return []
            }
        }.flatMap { $0 } // Flatten nested arrays to a single [String]
        
        // Step 2: Fetch corresponding deals from the database
        return try await fetchDealsFromDatabase(objectIDs: objectIDs)
    }
    
    
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
                if let deal = deal {
                    result.append(deal)
                }
            }
        }
        
        // Sort deals by dateTime in descending order (newest first)
        let sortedDeals = deals.sorted { firstDeal, secondDeal in
            guard let firstTimestamp = firstDeal.dateTime?.seconds,
                  let secondTimestamp = secondDeal.dateTime?.seconds else {
                return false // Treat as unordered if dateTime is missing
            }
            return firstTimestamp > secondTimestamp // Descending order
        }
        
        return sortedDeals
    }
}

