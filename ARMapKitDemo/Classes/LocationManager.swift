//
//  LocationManager.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation
import CoreLocation

// Define a protocol for classes that wish to receive location updates from LocationManager
protocol LocationManagerDelegate: AnyObject {
    // Called when there's a new user location update
    func didUpdateUserLocation(_ locationManager: LocationManager, location: CLLocation)
    // Called when a significant location change is detected based on a predefined distance
    func didUpdateReloadLocation(_ locationManager: LocationManager, location: CLLocation)
}

// Provide default implementation to make methods optional
extension LocationManagerDelegate {
    func didUpdateUserLocation(_ locationManager: LocationManager, location: CLLocation) {}
    func didUpdateReloadLocation(_ locationManager: LocationManager, location: CLLocation) {}
}

class LocationManager: NSObject {
    weak var delegate: LocationManagerDelegate?

    // Configure the CLLocationManager
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.distanceFilter = 15 // Update events will be generated only after moving this distance
        locationManager.delegate = self
        return locationManager
    }()
    var reloadDistanceFilter: CLLocationDistance = 100 // Distance in meters to trigger reload location updates
    /// Ignore locations with accuracy estimates larger than this value. In meters.
    var minimumLocationHorizontalAccuracy: Double = 500
    /// Ignore locations that are older than this value. In seconds.
    var minimumLocationAge: Double = 30

    // Use a DispatchQueue to safely access or modify location properties across multiple threads
    private let queue = DispatchQueue(label: "ThreadSafeLocation.queue", attributes: .concurrent)
    private var _userLocation: CLLocation?
    private var _lastUpdatedLocation: Date?

    // Thread-safe accessors for userLocation and lastUpdatedLocation
    var lastUpdatedLocation: Date? {
        get {
            queue.sync { _lastUpdatedLocation }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?._lastUpdatedLocation = newValue
            }
        }
    }
    var userLocation: CLLocation? {
        get {
            queue.sync { _userLocation }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?._userLocation = newValue
            }
        }
    }

    // Check if location permissions are granted
    var isPermissionGranted: Bool {
        let status: CLAuthorizationStatus
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
        case .restricted, .denied:
            return false
        default:
            return true
        }
    }

    // Start updating location or request permissions if needed
    func startUpdatingLocation(_ whenPermissionRequired: (() -> Void)? = nil) {
        let status: CLAuthorizationStatus
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
        case .restricted, .denied:
            whenPermissionRequired?()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            requestLocationAuthorization()
        }
    }

    // Request location authorization from the user
    func requestLocationAuthorization() {
        if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    // Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    // Handle changes in location authorization
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .restricted, .denied:
                self.stopUpdatingLocation()
            case .authorizedAlways, .authorizedWhenInUse:
                manager.startUpdatingLocation()
            default:
                self.requestLocationAuthorization()
            }
        }
    }

    // Handle new location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        // Filter out old or inaccurate location updates
        let age = -location.timestamp.timeIntervalSinceNow
        if age < -self.minimumLocationAge || location.horizontalAccuracy > self.minimumLocationHorizontalAccuracy || location.horizontalAccuracy < 0 {
            print("Ignoring location update: age: \(age) sec, accuracy: \(location.horizontalAccuracy) meters")
            return
        }

        // Notify delegate of new or significant location changes
        if let _ = self.lastUpdatedLocation, let previousLocation = self.userLocation, location.distance(from: previousLocation) > self.reloadDistanceFilter {
            self.userLocation = location
            self.delegate?.didUpdateReloadLocation(self, location: location)
        } else {
            self.userLocation = location
            if self.lastUpdatedLocation == nil {
                self.delegate?.didUpdateUserLocation(self, location: location)
            }
        }

        lastUpdatedLocation = Date()
    }
    // Handle location update failures
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
