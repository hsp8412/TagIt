//
//  LocationManager.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-11-17.
//

import CoreLocation
import Foundation
import UIKit

/// A manager responsible for handling location services, including requesting permissions,
/// tracking user location, and handling related errors.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// The underlying `CLLocationManager` instance used to interact with Core Location services.
    private var locationManager = CLLocationManager()

    /// The user's current location. Published to notify observers of location updates.
    @Published var userLocation: CLLocation?

    /// The current authorization status for location services. Published to notify observers of status changes.
    @Published var authorizationStatus: CLAuthorizationStatus?

    /// Holds error messages related to location services. Published to provide user feedback.
    @Published var locationError: String?

    /// Indicates whether continuous location tracking is enabled. Set to `true` for ongoing updates.
    private var isContinuousTracking = true

    /// Initializes the `LocationManager` by setting up the `CLLocationManager` delegate and desired accuracy.
    ///
    /// Permissions are not requested upon initialization to allow the app to control when to prompt the user.
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Permissions are requested explicitly via `requestLocationPermission()`
    }

    /// Requests the user's permission to access location services.
    ///
    /// The method handles different authorization statuses:
    /// - `.notDetermined`: Prompts the user for permission.
    /// - `.restricted` or `.denied`: Displays an error message and prompts the user to open Settings.
    /// - `.authorizedWhenInUse` or `.authorizedAlways`: Starts updating the user's location.
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
            promptToOpenSettings()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    /// Delegate method called when the authorization status changes.
    ///
    /// - Parameters:
    ///   - manager: The location manager object reporting the event.
    ///   - status: The new authorization status.
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .denied:
                self.locationError = "Location permission denied. Please enable location permissions in Settings."
            // Uncomment the line below if you want to prompt the user to open Settings immediately upon denial
            // self.promptToOpenSettings()
            case .restricted:
                self.locationError = "Location services are restricted. Check your device's settings."
            case .notDetermined:
                // Do nothing; permission has not been requested yet
                break
            @unknown default:
                break
            }
        }
    }

    /// Delegate method called when new location data is available.
    ///
    /// - Parameters:
    ///   - manager: The location manager object reporting the event.
    ///   - locations: An array of `CLLocation` objects containing the location data.
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = latestLocation
            self.locationError = nil // Clear any previous error
        }
        if !isContinuousTracking {
            locationManager.stopUpdatingLocation()
        }
    }

    /// Delegate method called when the location manager fails to retrieve a location.
    ///
    /// - Parameters:
    ///   - manager: The location manager object reporting the event.
    ///   - error: The error object containing details of the failure.
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Failed to get location: \(error.localizedDescription)"
        }
        // Optionally retry for recoverable errors
        if (error as NSError).code == CLError.network.rawValue {
            locationManager.startUpdatingLocation()
        }
    }

    /// Prompts the user with an alert to open the app's settings, allowing them to grant location permissions.
    ///
    /// This method is called when location services are denied or restricted.
    private func promptToOpenSettings() {
        DispatchQueue.main.async {
            // Get the active UIWindowScene
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController
            else {
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
