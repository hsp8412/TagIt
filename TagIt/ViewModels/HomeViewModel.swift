//
//  HomeViewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-22.
//

import CoreLocation
import Foundation

/**
 Manages the state and logic for displaying and filtering deals.

 This view model handles fetching all deals, applying various filters (such as latest, popular, and nearby),
 managing loading and error states, and associating deals with their respective stores.
 */
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The list of deals currently displayed based on applied filters.
    @Published var shownDeals: [Deal] = []

    /// The complete list of all fetched deals.
    @Published var allDeals: [Deal] = []

    /// Indicates whether data is currently being loaded.
    @Published var isLoading: Bool = true

    /// An optional error message to display if fetching deals fails.
    @Published var errorMessage: String?

    /// The list of available filters for sorting deals.
    @Published var filters: [Filter] = [
        Filter(id: "1", label: "Latest", value: "todaysDeal", icon: "tag", isSelected: true),
        Filter(id: "2", label: "Popular", value: "hotDeal", icon: "flame.fill", isSelected: false),
        Filter(id: "3", label: "Nearby", value: "nearbyDeal", icon: "mappin", isSelected: false),
    ]

    // MARK: - Properties

    /// Manages location-related functionalities.
    var locationManager = LocationManager()

    // MARK: - Public Methods

    /**
         Resets all filters to their default states.

         This method sets the "Latest" filter as selected and deselects all other filters.
     */
    func resetFilters() {
        for index in filters.indices {
            if filters[index].value == "todaysDeal" {
                filters[index].isSelected = true
            } else {
                filters[index].isSelected = false
            }
        }
    }

    /**
         Toggles the selected filter based on the provided filter ID.

         - Parameter id: The unique identifier of the filter to be selected.

         This method updates the selected filter and fetches deals corresponding to the selected filter.
     */
    func toggleFilter(id: String) {
        errorMessage = nil
        for index in filters.indices {
            if filters[index].id == id {
                filters[index].isSelected = true
            } else {
                filters[index].isSelected = false
            }
        }
        let selectedFilter = filters.first(where: { $0.isSelected })
        if let selectedFilter {
            switch selectedFilter.value {
            case "todaysDeal":
                fetchWeeklyDeals()
            case "hotDeal":
                fetchHottestDeals()
            case "nearbyDeal":
                fetchNearbyDeals()
            default:
                displayAllDeals()
            }
        } else {
            displayAllDeals()
        }
    }

    /**
         Fetches all deals and updates the displayed deals.

         This function retrieves all available deals, associates each deal with its corresponding store,
         and applies the default "Latest" filter.
     */
    func fetchAllDeals() {
        isLoading = true
        errorMessage = nil
        DealService.shared.getDeals { [weak self] result in
            switch result {
            case let .success(fetchedDeals):
                self?.allDeals = fetchedDeals
                self?.fetchStoresForDeals()
                self?.shownDeals = self?.allDeals ?? []
                self?.fetchWeeklyDeals()
                self?.isLoading = false
            case let .failure(error):
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }

    /**
         Fetches deals based on a search query and updates the displayed deals.

         - Parameter searchText: A string containing the search query to filter the deals.

         This function retrieves deals that match the search query and updates the `shownDeals` array.
     */
    func fetchSearchDeals(searchText: String) {
        isLoading = true
        errorMessage = nil

        for index in filters.indices {
            filters[index].isSelected = false
        }

        StoreService.shared.getDeals(query: searchText) { [weak self] result in
            switch result {
            case let .success(deals):
                self?.shownDeals = deals
                self?.isLoading = false
            case let .failure(error):
                print("Error fetching searched deals: \(error)")
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }

    /**
         Displays all fetched deals without applying any filters.

         This method sets the `shownDeals` array to include all available deals.
     */
    func displayAllDeals() {
        isLoading = true
        errorMessage = nil
        shownDeals = allDeals
        isLoading = false
    }

    /**
         Fetches deals posted within the last week and updates the displayed deals.

         This function filters deals based on their posting date and updates the `shownDeals` array accordingly.
     */
    func fetchWeeklyDeals() {
        isLoading = true
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date()) // Today's 12:00 AM
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: startOfToday) ?? Date() // 7 days ago from today

        // Filter deals posted within the last week
        let weeklyDeals = allDeals.filter { deal in
            if let dealDate = deal.dateTime?.dateValue() {
                return dealDate >= startOfWeek
            }
            return false // Exclude deals with nil dateTime
        }

        shownDeals = weeklyDeals
        isLoading = false
    }

    /**
         Fetches the hottest deals sorted by the difference between upvotes and downvotes.

         This function retrieves deals from the current month, sorts them based on their popularity,
         and updates the `shownDeals` array with the top deals.
     */
    func fetchHottestDeals() {
        isLoading = true

        let calendar = Calendar.current
        let today = Date()
        guard
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
            let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else {
            isLoading = false
            return
        }

        // Filter deals within the current month
        let currentMonthDeals = allDeals.filter { deal in
            if let dealDate = deal.dateTime?.dateValue() {
                return dealDate >= startOfMonth && dealDate <= endOfMonth
            }
            return false // Exclude deals with nil dateTime
        }

        // Sort by the difference between upvotes and downvotes in descending order
        let hotDeals = currentMonthDeals
            .sorted {
                ($0.upvote - $0.downvote) > ($1.upvote - $1.downvote) // Sort by vote difference descending
            }

        shownDeals = Array(hotDeals)
        isLoading = false
    }

    /**
         Fetches deals sorted by proximity to the user's current location.

         This function retrieves deals within a 5-kilometer radius of the user's location and sorts them
         based on their distance from the user.

         **Note:** This function requires location permissions to be granted.
     */
    func fetchNearbyDeals() {
        locationManager.requestLocationPermission()
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            isLoading = true
            return
        }
        guard let userLocation = locationManager.userLocation else {
            errorMessage = "Cannot filter deals by distance: No user location"
            return
        }
        isLoading = true

        let nearbyDeals = allDeals
            .compactMap { deal -> (deal: Deal, distance: Double)? in
                guard let store = deal.store else { return nil }

                let storeLocation = CLLocation(latitude: store.latitude, longitude: store.longitude)
                let distance = storeLocation.distance(from: userLocation) // Distance in meters
                return distance <= 5000 ? (deal, distance) : nil
            }
            .sorted { $0.distance < $1.distance } // Sort by distance ascending
            .map(\.deal) // Extract the deals only
        shownDeals = nearbyDeals
        isLoading = false
    }

    // MARK: - Private Methods

    /**
         Fetches and associates stores with each deal.

         This function iterates through all deals, retrieves their corresponding store information
         based on the `locationId`, and updates each deal with its associated store.
     */
    private func fetchStoresForDeals() {
        let group = DispatchGroup() // Use DispatchGroup to wait for all queries

        for index in allDeals.indices {
            let deal = allDeals[index]
            group.enter() // Enter the group for each deal

            // Query store by locationId
            guard let locationId = deal.locationId else {
                print("Error: Deal \(deal.id ?? "unknown") has no locationId")
                group.leave()
                continue // Skip this deal
            }
            StoreService.shared.getStoreById(id: locationId) { result in
                switch result {
                case let .success(store):
                    DispatchQueue.main.async {
                        self.allDeals[index].store = store // Update the store field
                    }
                case let .failure(error):
                    print("Error fetching store for deal \(deal.id ?? "unknown"): \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        // Notify when all store fetch operations are complete
        group.notify(queue: .main) {
            print("All stores have been fetched and associated with their respective deals.")
        }
    }
}

/**
 Represents a filter option for sorting deals.

 This struct defines the properties of a filter, including its identifier, display label, value,
 associated icon, and selection state.
 */
struct Filter: Identifiable {
    /// The unique identifier for the filter.
    let id: String

    /// The display label of the filter.
    let label: String

    /// The value associated with the filter, used to determine the filter's functionality.
    var value: String

    /// The icon representing the filter.
    let icon: String

    /// Indicates whether the filter is currently selected.
    var isSelected: Bool
}
