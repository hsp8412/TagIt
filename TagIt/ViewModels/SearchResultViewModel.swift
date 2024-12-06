//
//  SearchResultViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//

import Combine
import MapKit
import SwiftUI

/**
 ViewModel responsible for handling search results, including fetching and filtering deals,
 managing map annotations, and updating the map region based on user location and selected filters.
 */
class SearchResultViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties

    /// Indicates whether to show detailed view for a selected deal.
    @Published var showDetails: Bool = false
    /// The currently selected map item.
    @Published var selection: MKMapItem?
    /// The search query entered by the user.
    @Published var searchText: String
    /// The current position of the map camera.
    @Published var position: MapCameraPosition = .automatic
    /// The user's current location.
    @Published var currentLocation: CLLocation?
    /// Annotations to be displayed on the map.
    @Published var mapAnnotations: [CustomAnnotation] = []
    /// Indicates whether deals are available for the search query.
    @Published var hasDeals: Bool = true
    /// Indicates whether a loading operation is in progress.
    @Published var loading: Bool = true
    /// Tags for filtering search results by distance.
    let tags: [Tag] = [
        Tag(label: "1km", value: 1000, color: .red),
        Tag(label: "5km", value: 5000, color: .blue),
        Tag(label: "10km", value: 10000, color: .green),
    ]
    /// The currently selected distance filter tag.
    @Published var selectedTag: Tag? = nil

    /// All available map annotations before applying filters.
    var allAnnotations: [CustomAnnotation] = []

    // MARK: - Private Properties

    /// A set of Combine subscriptions for managing data streams.
    private var cancellables = Set<AnyCancellable>()
    /// Observes and manages the user's location.
    @ObservedObject var locationManager: LocationManager
    /// A list of deals fetched for the current search query.
    var deals: [Deal] = []

    // MARK: - Initializer

    /**
     Initializes the SearchResultViewModel with a search query and a LocationManager instance.

     - Parameters:
       - searchText: The initial search query.
       - locationManager: The LocationManager instance for tracking user location.
     */
    init(searchText: String, locationManager: LocationManager) {
        self.searchText = searchText
        self.locationManager = locationManager
        super.init()
        setupBindings()
    }

    // MARK: - Setup

    /// Sets up bindings to observe location updates and handle location errors.
    private func setupBindings() {
        locationManager.$userLocation
            .compactMap(\.self) // Filter out nil values
            .sink { [weak self] location in
                DispatchQueue.main.async {
                    self?.currentLocation = location
                }
            }
            .store(in: &cancellables)

        locationManager.$locationError
            .sink { [weak self] error in
                if let error {
                    print("Location Error: \(error)")
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetching Deals

    /**
     Fetches deals based on the current search query and updates map annotations.
     */
    func fetchDeals() {
        StoreService.shared.getDeals(query: searchText) { [weak self] result in
            switch result {
            case let .success(deals):
                self?.deals = deals
                self?.hasDeals = !deals.isEmpty
                DispatchQueue.main.async {
                    self?.mapAnnotations = deals.compactMap { deal in
                        guard let store = deal.store else { return nil }
                        let storeLocation = CLLocation(latitude: store.latitude, longitude: store.longitude)
                        let storeDistance = self?.currentLocation?.distance(from: storeLocation) ?? 0
                        return CustomAnnotation(
                            locationId: store.id ?? "",
                            title: store.name,
                            subtitle: deal.productText,
                            coordinate: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude),
                            store: store,
                            distance: storeDistance
                        )
                    }
                    self?.allAnnotations = self?.mapAnnotations ?? []
                    self?.loading = false
                    self?.updateMapRegion()
                }
            case let .failure(error):
                print("Error fetching deals: \(error)")
                self?.hasDeals = false
            }
        }
    }

    // MARK: - Filtering Deals

    /**
     Applies the selected distance filter to the map annotations.
     */
    func applyFilters() {
        guard let selectedTag else {
            DispatchQueue.main.async {
                self.mapAnnotations = self.allAnnotations
                self.hasDeals = !self.allAnnotations.isEmpty
                self.updateMapRegion()
            }
            return
        }

        let maxDistance = Double(selectedTag.value)
        let filteredAnnotations = allAnnotations.filter { $0.distance ?? 0 <= maxDistance }

        DispatchQueue.main.async {
            self.mapAnnotations = filteredAnnotations
            self.hasDeals = !filteredAnnotations.isEmpty
            self.updateMapRegion()
        }
    }

    // MARK: - Map Region Updates

    /**
     Updates the map region to encompass all current annotations and the user's location.
     */
    func updateMapRegion() {
        guard let currentLocation else { return }

        let coordinates = mapAnnotations.map(\.coordinate) + [currentLocation.coordinate]
        let latitudeDelta = coordinates.map(\.latitude).max()! - coordinates.map(\.latitude).min()!
        let longitudeDelta = coordinates.map(\.longitude).max()! - coordinates.map(\.longitude).min()!

        DispatchQueue.main.async {
            self.position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (coordinates.map(\.latitude).max()! + coordinates.map(\.latitude).min()!) / 2,
                    longitude: (coordinates.map(\.longitude).max()! + coordinates.map(\.longitude).min()!) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: latitudeDelta * 1.2, // Add some padding
                    longitudeDelta: longitudeDelta * 1.2
                )
            ))
        }
    }

    // MARK: - CLLocationManagerDelegate Methods

    /// Updates the user's location and map region when location changes.
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location
                self.updateMapRegion()
            }
        }
    }

    /// Handles location errors.
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}

/**
 Represents a custom map annotation for a store location and its associated deal.
 */
struct CustomAnnotation: Identifiable {
    /// A unique identifier for the annotation.
    let id = UUID()
    /// The location ID of the store.
    let locationId: String
    /// The title of the annotation, usually the store name.
    let title: String
    /// The subtitle of the annotation, typically the product text.
    let subtitle: String
    /// The geographical coordinate of the annotation.
    let coordinate: CLLocationCoordinate2D
    /// The store associated with this annotation.
    let store: Store?
    /// The distance from the user's current location to this annotation.
    let distance: Double?
}

/**
 Represents a filter tag for categorizing deals by distance.
 */
struct Tag {
    /// The label of the tag, e.g., "1km".
    let label: String
    /// The distance value associated with the tag in meters.
    let value: Int
    /// The color associated with the tag for UI display.
    let color: Color
}
