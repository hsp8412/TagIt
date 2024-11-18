//
//  SearchResultViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//
import SwiftUI
import MapKit
import Combine

class SearchResultViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var searchText:String
    @Published var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),  // Default location
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var mapAnnotations: [CustomAnnotation] = [] // For map annotations
    
    init(searchText:String){
        self.searchText = searchText
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    
    func requestLocationPermission() {
        locationManager.delegate = self  // Set delegate
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func fetchDeals() {
        StoreService.shared.getDeals(query:searchText) { [weak self] result in
            switch result {
            case .success(let deals):
                for deal in deals {
                    if let store = deal.store {
                        print("Latitude: \(store.latitude)")
                        print("Longitude: \(store.longitude)")
                    }
                }
                DispatchQueue.main.async {
                    self?.mapAnnotations = deals.compactMap { deal in
                        guard let store = deal.store else { return nil }
                        return CustomAnnotation(
                            title: store.name,
                            subtitle: deal.productText,
                            coordinate: CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
                        )
                    }
                }
                
            case .failure(let error):
                print("Error fetching deals: \(error)")
            }
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error)")
    }
}


struct CustomAnnotation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
}
