//
//  LocationManager.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var userLocation: CLLocation? // Holds the current location
    @Published var authorizationStatus: CLAuthorizationStatus? // Tracks the current authorization status
    @Published var locationError: String? // Holds error messages for user feedback
    
    private var isContinuousTracking = true // Set to true if continuous tracking is needed
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Do not request permissions here; let the app control when to do so
    }
    
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        print(status)
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            DispatchQueue.main.async {
                self.locationError = "Location services are disabled. Please enable them in Settings."
            }
            self.promptToOpenSettings()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied:
                self.locationError = "Location permission denied. Please enable location permissions in Settings."
//                self.promptToOpenSettings()
            case .restricted:
                self.locationError = "Location services are restricted. Check your device's settings."
                
            default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = latestLocation
            self.locationError = nil // Clear any previous error
        }
        if !isContinuousTracking {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Failed to get location: \(error.localizedDescription)"
        }
        // Optionally retry for recoverable errors
        if (error as NSError).code == CLError.network.rawValue {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func promptToOpenSettings() {
        DispatchQueue.main.async {
            // Get the active UIWindowScene
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                return
            }
            
            let alert = UIAlertController(
                title: "Location Permission Needed",
                message: "To use this feature, please enable location permissions in Settings.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            
            rootViewController.present(alert, animated: true)
        }
    }
}

