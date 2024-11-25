//
//  SearchResultDetailViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-19.
//

import Foundation

class SearchResultDetailViewModel:ObservableObject{
    @Published var store:Store
    @Published var dealsFromStore:[Deal]
    
    init(store: Store, dealsFromStore:[Deal]){
        self.store = store
        self.dealsFromStore = dealsFromStore
    }
    
    func filterDealsByStore(storeId: String, deals: [Deal]) -> [Deal] {
        return deals.filter { deal in
            if let locationId = deal.locationId {
                return locationId == storeId
            }
            return false
        }
    }
}
