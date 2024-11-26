//
//  HomeViewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-22.
//
import Foundation

/// A ViewModel for managing and fetching deals in the app.
class HomeViewModel: ObservableObject {
    @Published var shownDeals: [Deal] = [] // List of deals to display
    @Published var isLoading: Bool = true // Indicates whether data is loading
    @Published var errorMessage: String? // Holds any error message
    @Published var todaysDeal: Bool = false // Filter for today's deals
    @Published var hotDeal: Bool = false // Filter for hottest deals
    @Published var nearbyDeal: Bool = false // Filter for nearby deals
    
    /**
     Fetches all deals and updates `shownDeals`.

     - This function fetches all available deals and updates the `shownDeals` property. It also handles
     loading states and any errors that occur during fetching.
     
     - Parameter none: This function does not accept any parameters.
     
     - Returns: Updates the `shownDeals` array with the fetched deals.
     */
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

    /**
     Fetches deals based on a search query and updates `shownDeals`.

     - This function fetches deals that match the provided search query and updates the `shownDeals` array.
     It also handles loading states and any errors that occur during fetching.
     
     - Parameter searchText: A string that contains the search query to filter the deals.
     
     - Returns: Updates the `shownDeals` array with the filtered deals.
     */
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

    /**
     Fetches deals posted within the last 24 hours and within the last 7 days.

     - This function fetches deals and filters those within the last 24 hours. Then it sorts the deals
     by their post date in descending order, keeping only those within the last week.
     
     - Parameter none: This function does not accept any parameters.
     
     - Returns: Updates the `shownDeals` array with deals posted within the last 24 hours and up to 7 days.
     */
    func fetchTodaysDeals() {
        isLoading = true
        errorMessage = nil
        
        DealService.shared.getDeals { [weak self] result in
            switch result {
            case .success(let fetchedDeals):
                let now = Date()
                let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
                let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
                
                self?.shownDeals = fetchedDeals
                    .compactMap { $0.dateTime != nil ? $0 : nil } // Remove deals with nil dateTime
                    .sorted {
                        let firstDate = $0.dateTime!.dateValue()
                        let secondDate = $1.dateTime!.dateValue()
                        
                        // Prioritize within 24 hours first
                        if firstDate >= twentyFourHoursAgo && secondDate < twentyFourHoursAgo {
                            return true
                        } else if firstDate < twentyFourHoursAgo && secondDate >= twentyFourHoursAgo {
                            return false
                        }
                        
                        // Then sort by date descending
                        return firstDate > secondDate
                    }
                    .filter { $0.dateTime!.dateValue() >= oneWeekAgo } // Keep deals up to a week old
                self?.isLoading = false
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }

    /**
     Fetches the hottest deals sorted by the difference between upvotes and downvotes.

     - This function fetches all available deals, filters them to include only those from the last month,
     and then sorts them based on the difference between upvotes and downvotes.
     
     - Parameter none: This function does not accept any parameters.
     
     - Returns: Updates the `shownDeals` array with the hottest deals sorted by upvotes minus downvotes.
     */
    func fetchHottestDeals() {
        isLoading = true
        errorMessage = nil
        
        DealService.shared.getDeals { [weak self] result in
            switch result {
            case .success(let deals):
                // Calculate the cutoff date for one month ago
                let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())
                
                // Filter deals to include only those within the last month
                let recentDeals = deals.filter {
                    if let dealDate = $0.dateTime?.dateValue() {
                        return dealDate >= (oneMonthAgo ?? Date.distantPast)
                    }
                    return false
                }
                
                // Sort the recent deals by (upvotes - downvotes) in descending order
                self?.shownDeals = recentDeals.sorted {
                    ($0.upvote - $0.downvote) > ($1.upvote - $1.downvote)
                }
                self?.isLoading = false
            case .failure(let error):
                print("Error fetching hottest deals: \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }

    /**
     Fetches deals sorted by the distance of stores.

     - This function is a placeholder and not yet implemented.
     
     - Parameter none: This function does not accept any parameters.
     
     - Returns: The `shownDeals` array will be updated once the function is fully implemented.
     */
    func fetchNearbyDeals() {
        isLoading = true
        errorMessage = nil
        // Functionality to fetch deals based on store distance is not implemented yet.
    }
}
