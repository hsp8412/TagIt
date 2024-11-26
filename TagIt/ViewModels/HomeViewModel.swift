//
//  HomeViewModel.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-22.
//
import Foundation
import CoreLocation
class HomeViewModel: ObservableObject {
    @Published var shownDeals: [Deal] = []
    @Published var allDeals: [Deal] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    //    @Published var todaysDeal: Bool = false
    //    @Published var hotDeal: Bool = false
    //    @Published var nearbyDeal: Bool = false
    
    @Published var filters:[Filter] = [
        Filter(id:"1", label: "Now", value: "todaysDeal", icon:"sparkles" ,isSelected:true),
        Filter(id:"2", label: "Nearby", value: "nearbyDeal", icon:"mappin", isSelected:false),
        Filter(id:"3",label: "Hot", value: "hotDeal", icon:"flame.fill",isSelected: false)
    ]
    
    var locationManager = LocationManager()
    
    func toggleFilter(id: String) {
        for index in filters.indices {
            if filters[index].id == id{
                filters[index].isSelected = true
            }else{
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
        }else{
            displayAllDeals()
        }
    }
    
    
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
        DealService.shared.getDeals { [weak self] result in
            switch result {
            case .success(let fetchedDeals):
                self?.allDeals = fetchedDeals
                self?.fetchStoresForDeals()
                self?.shownDeals = self?.allDeals ?? []
                self?.isLoading = false
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
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
        
        for index in filters.indices {
            
            filters[index].isSelected = false
            
        }
        
        
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
    
    func displayAllDeals(){
        isLoading = true
        errorMessage = nil
        shownDeals = allDeals
        isLoading = false
    }
    
    // NOT IMPLEMENTED YET
    func fetchWeeklyDeals() {
        isLoading = true
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date()) // Today's 12:00 AM
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: startOfToday) ?? Date() // 7 days ago from today
        
        // Filter deals
        let weeklyDeals = allDeals.filter { deal in
            if let dealDate = deal.dateTime?.dateValue() { // Safely unwrap the optional Timestamp
                return dealDate >= startOfWeek && dealDate < startOfToday
            }
            return false // Exclude deals with nil dateTime
        }
        shownDeals = weeklyDeals
        isLoading = false
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
            if let dealDate = deal.dateTime?.dateValue() { // Safely unwrap the optional Timestamp
                return dealDate >= startOfMonth && dealDate <= endOfMonth
            }
            return false // Exclude deals with nil dateTime
        }
        
        // Sort by votes and take the top 5
        let hotDeals = currentMonthDeals
            .sorted {
                ($0.upvote - $0.downvote) > ($1.upvote - $1.downvote) // Sort by vote descending
            }
        
        shownDeals = Array(hotDeals)
        isLoading = false
    }
    
    
    /**
     Fetches deals sorted by the distance of stores.
     
     - This function is a placeholder and not yet implemented.
     
     - Parameter none: This function does not accept any parameters.
     
     - Returns: The `shownDeals` array will be updated once the function is fully implemented.
     */
    func fetchNearbyDeals() {
        locationManager.requestLocationPermission()
        guard locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways else {
            errorMessage = "Cannot filter deals by distance: Location permission not granted"
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
                return distance <= 1000 ? (deal, distance) : nil
            }
            .sorted { $0.distance < $1.distance } // Sort by distance ascending
            .map { $0.deal } // Extract the deals only
        shownDeals = nearbyDeals
        isLoading = false
    }
    
    func fetchStoresForDeals(){
        let group = DispatchGroup() // Use DispatchGroup to wait for all queries
        
        for index in allDeals.indices {
            let deal = allDeals[index]
            group.enter() // Enter the group for each deal
            
            // Query store by locationId
            guard let  locationId = deal.locationId else {
                print("Error: Deal \(deal.id!) has no locationId")
                continue // Skip this deal
            }
            StoreService.shared.getStoreById(id: deal.locationId!) { result in
                switch result {
                case .success(let store):
                    DispatchQueue.main.async {
                        self.allDeals[index].store = store // Update the store field
                    }
                case .failure(let error):
                    print("Error fetching store for deal \(deal.id!): \(error.localizedDescription)")
                }
                group.leave()
            }
        }
    }
}

struct Filter:Identifiable{
    let id: String
    let label: String
    let value: String
    let icon:String
    var isSelected: Bool
}
