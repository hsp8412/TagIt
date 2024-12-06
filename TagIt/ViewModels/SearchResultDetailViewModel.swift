//
//  SearchResultDetailViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-19.
//

import Foundation

/**
 ViewModel responsible for managing the details of a selected store and filtering deals related to that store.
 */
class SearchResultDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The store for which the details are being viewed.
    @Published var store: Store
    /// A list of deals available at the selected store.
    @Published var dealsFromStore: [Deal]

    // MARK: - Initializer

    /**
     Initializes the SearchResultDetailViewModel with a store and its associated deals.

     - Parameters:
       - store: The selected store whose details are being viewed.
       - dealsFromStore: A list of deals available at the selected store.
     */
    init(store: Store, dealsFromStore: [Deal]) {
        self.store = store
        self.dealsFromStore = dealsFromStore
    }

    // MARK: - Helper Functions

    /**
     Filters the list of deals by the store ID to only include deals from the specified store.

     - Parameters:
       - storeId: The ID of the store to filter deals by.
       - deals: The list of deals to filter.
     - Returns: A list of deals that belong to the specified store.
     */
    func filterDealsByStore(storeId: String, deals: [Deal]) -> [Deal] {
        deals.filter { deal in
            if let locationId = deal.locationId {
                return locationId == storeId
            }
            return false
        }
    }
}
