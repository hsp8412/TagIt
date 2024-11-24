//
//  SearchResultViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//
import SwiftUI
import MapKit
import Combine


class SearchResultViewModel: NSObject, ObservableObject {
    @Published var showDetails: Bool = false
    @Published var selection: MKMapItem?
    @Published var searchText:String
    //    @Published var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
//    var position:MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @Published var position:MapCameraPosition = .automatic
    //    @Published var region = MKCoordinateRegion(
    //        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),  // Default location
    //        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    //    )
    @Published var currentLocation: CLLocation?
    @Published var mapAnnotations: [CustomAnnotation] = [] // For map annotations
    @Published var hasDeals: Bool = true
    @Published var loading: Bool = true
    let tags:[Tag] = [
        Tag(label:"1km",value: 1000,color: .red),
        Tag(label:"5km",value:5000,color: .blue),
        Tag(label:"10km", value:10000,  color: .green)
    ]
    @Published var selectedTag:Tag?=nil
    
    var allAnnotations:[CustomAnnotation] = []
    
    
    private var cancellables = Set<AnyCancellable>()
    @ObservedObject var locationManager: LocationManager
    
    var deals : [Deal] = []
    
    
    init(searchText: String, locationManager: LocationManager) {
        self.searchText = searchText
        self.locationManager = locationManager
        super.init()
        setupBindings()
    }
    
    private func setupBindings() {
        // Update region when the user location changes
        locationManager.$userLocation
            .compactMap { $0 } // Filter out nil values
            .sink { [weak self] location in
                DispatchQueue.main.async {
                    self?.currentLocation = location // Save the location directly
                }
            }
            .store(in: &cancellables)
        
        // Handle location errors
        locationManager.$locationError
            .sink { [weak self] error in
                if let error = error {
                    print("Location Error: \(error)")
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchDeals() {
        StoreService.shared.getDeals(query:searchText) { [weak self] result in
            switch result {
            case .success(let deals):
                self?.deals = deals
                self?.hasDeals = !deals.isEmpty // Update hasDeals
                for deal in deals {
                    if let store = deal.store {
                        print("Latitude: \(store.latitude)")
                        print("Longitude: \(store.longitude)")
                    }
                }
                DispatchQueue.main.async {
                    self?.mapAnnotations = deals.compactMap { deal in
                        guard let store = deal.store else { return nil }
                        let storeLocation = CLLocation(latitude: store.latitude, longitude: store.longitude)
                        var storeDistance = 0.0;
                        if let currentLocation = self?.currentLocation {
                            storeDistance = storeLocation.distance(from: currentLocation)
                        }
                        return CustomAnnotation(
                            locationId:store.id ?? "",
                            title: store.name,
                            subtitle: deal.productText,
                            coordinate: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude),
                            store: deal.store ?? nil,
                            distance:storeDistance
                        )
                    }
                    self?.allAnnotations = self?.mapAnnotations ?? []
                    
                    self?.hasDeals = (!(self?.deals.isEmpty ?? true))
                    self?.loading = false // Loading complete
                    self?.updateMapRegion() // Update region to include all annotations
                }
                
            case .failure(let error):
                print("Error fetching deals: \(error)")
                self?.hasDeals = false // Assume no deals on failure
            }
        }
    }
    
    func applyFilters() {
        var maxDistance = 0.0
        guard let selectedTag = selectedTag else {
            // No filter applied, show all annotations
            print("123")
            DispatchQueue.main.async {
                self.mapAnnotations = self.allAnnotations
                print(self.mapAnnotations.count)
                self.hasDeals = !self.allAnnotations.isEmpty
                self.updateMapRegion()
            }
            return
        }
        maxDistance = Double(selectedTag.value)

        let filteredAnnotations = allAnnotations.filter { $0.distance ?? 0 <= maxDistance }

        DispatchQueue.main.async {
            self.mapAnnotations = filteredAnnotations
            self.hasDeals = !filteredAnnotations.isEmpty
            self.updateMapRegion() // Update region to include all annotations
        }
    }

    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location
                self.updateMapRegion() 
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
    
    func updateMapRegion() {
        guard let currentLocation = currentLocation else { return }

        let coordinates = allAnnotations.map { $0.coordinate } + [currentLocation.coordinate]
        let latitudeDelta = coordinates.map { $0.latitude }.max()! - coordinates.map { $0.latitude }.min()!
        let longitudeDelta = coordinates.map { $0.longitude }.max()! - coordinates.map { $0.longitude }.min()!

        DispatchQueue.main.async {
            self.position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (coordinates.map { $0.latitude }.max()! + coordinates.map { $0.latitude }.min()!) / 2,
                    longitude: (coordinates.map { $0.longitude }.max()! + coordinates.map { $0.longitude }.min()!) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: latitudeDelta * 1.2, // Add some padding
                    longitudeDelta: longitudeDelta * 1.2
                )
            ))
        }
    }

}




struct CustomAnnotation: Identifiable {
    let id = UUID()
    let locationId: String
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let store: Store?
    let distance: Double?
}

struct Tag{
    let label:String
    let value:Int
    let color:Color
}
