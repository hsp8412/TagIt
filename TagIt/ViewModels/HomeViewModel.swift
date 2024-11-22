//
//  HomeViewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-22.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var shownDeals: [Deal] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    func fetchAllDeals() {
        isLoading = true
        errorMessage = nil

        DealService.shared.getDeals { result in
            switch result {
            case .success(let fetchedDeals):
                self.shownDeals = fetchedDeals
                self.isLoading = false
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func fetchSearchDeals(searchText: String) {
        isLoading = true
        errorMessage = nil
        
        StoreService.shared.getDeals(query: searchText) { [weak self] result in
            switch result {
            case .success(let deals):
                self?.shownDeals = deals
                self?.isLoading = false

            case .failure(let error):
                print("Error fetching searched deals: \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    // NOT IMPLEMENTED YET
    func fetchTodaysDeals() {
        isLoading = true
        errorMessage = nil
    }
    
    // Fetch sorted deals by upvotes - downvotes?
    func fetchHottestDeals() {
        isLoading = true
        errorMessage = nil
    }
    
    // Fetch sorted deals by distance of stores
    func fetchDealsClosedTo() {
        isLoading = true
        errorMessage = nil
    }
}
