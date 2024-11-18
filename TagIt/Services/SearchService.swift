//
//  SearchService.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-18.
//

import Foundation
import Search
import FirebaseCore

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
        
        // Step 1: Extract and map hits to Deal
        let deals = response.results.compactMap { result in
            switch result {
            case .searchResponse(let searchResponse):
                return searchResponse.hits.compactMap { dealHit in
                    mapHitToDeal(hit: dealHit) // Transform DealHit to Deal
                }
            case .searchForFacetValuesResponse:
                return nil // Ignore facet value responses
            }
        }.flatMap { $0 } // Flatten nested arrays to a single [Deal]
        
        return deals
    }
    
    func mapHitToDeal(hit: DealHit) -> Deal {
        return Deal(
            id: hit.objectID,
            userID: hit.userID,
            photoURL: hit.photoURL,
            productText: hit.productText,
            postText: hit.postText,
            price: hit.price,
            location: hit.location,
            date: hit.date,
            commentIDs: hit.commentIDs,
            upvote: hit.upvote,
            downvote: hit.downvote,
            locationId: hit.locationId,
            dateTime: Timestamp(seconds: Int64(hit.dateTime / 1000), nanoseconds: Int32((hit.dateTime % 1000) * 1_000_000))
        )
    }
}

