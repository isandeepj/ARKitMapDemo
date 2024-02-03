//
//  CLLocation.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation
import CoreLocation

/// Calculates the great-circle distance between two CLLocationCoordinate2D points.
func -(left: CLLocationCoordinate2D, right: CLLocationCoordinate2D) -> CLLocationDistance {
    // Uses Haversine formula for calculating distances on a sphere.
    let leftLatRadian = left.latitude.toRadians()
    let leftLonRadian = left.longitude.toRadians()

    let rightLatRadian = right.latitude.toRadians()
    let rightLonRadian = right.longitude.toRadians()

    let a = pow(sin((rightLatRadian - leftLatRadian) / 2), 2)
        + pow(sin((rightLonRadian - leftLonRadian) / 2), 2) * cos(leftLatRadian) * cos(rightLatRadian)

    return 2 * atan2(sqrt(a), sqrt(1 - a))
}

extension CLLocation {
    /// Calculates the bearing to another location in radians.
    func bearingToLocationRadian(_ destinationLocation: CLLocation) -> Double {
        // Formula to compute the initial bearing (or forward azimuth) between two points.
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()

        let lat2 = destinationLocation.coordinate.latitude.toRadians()
        let lon2 = destinationLocation.coordinate.longitude.toRadians()
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x)
        return radiansBearing
    }

    /// Translates the location by specified meters in latitude, longitude, and altitude.
    func translatedLocation(with latitudeTranslation: Double, longitudeTranslation: Double, altitudeTranslation: Double) -> CLLocation {
        // Adjusts the current location by specified translations.
        let latitudeCoordinate = self.coordinate.coordinate(with: 0, and: latitudeTranslation)
        let longitudeCoordinate = self.coordinate.coordinate(with: 90, and: longitudeTranslation)
        let coordinate = CLLocationCoordinate2D(latitude: latitudeCoordinate.latitude, longitude: longitudeCoordinate.longitude)
        let altitude = self.altitude + altitudeTranslation

        return CLLocation(coordinate: coordinate, altitude: altitude, horizontalAccuracy: self.horizontalAccuracy, verticalAccuracy: self.verticalAccuracy, timestamp: self.timestamp)
    }

    /// Determines the best location estimate based on accuracy and recency from an array of locations.
    static func bestLocationEstimate(locations: [CLLocation]) -> CLLocation? {
        // Sorts locations by accuracy and timestamp, selecting the best candidate.
        let sortedLocationEstimates = locations.sorted(by: {
            if $0.horizontalAccuracy == $1.horizontalAccuracy {
                return $0.timestamp > $1.timestamp
            }
            return $0.horizontalAccuracy < $1.horizontalAccuracy
        })
        return sortedLocationEstimates.first
    }
}

extension CLLocationCoordinate2D: Equatable {
    /// Compares two CLLocationCoordinate2D instances for equality.
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    /// Calculates the direction (bearing) to another coordinate.
    func calculateDirection(to coordinate: CLLocationCoordinate2D) -> Double {
        // Mathematical formula to calculate bearing from one coordinate to another.
        let a = sin(coordinate.longitude.toRadians() - longitude.toRadians()) * cos(coordinate.latitude.toRadians())
        let dLat = cos(latitude.toRadians()) * sin(coordinate.latitude.toRadians()) - sin(latitude.toRadians())
        let dLon = cos(coordinate.latitude.toRadians()) * cos(coordinate.longitude.toRadians() - longitude.toRadians())
        let b =  dLat * dLon
        return atan2(a, b)
    }

    /// Public method to get direction in degrees.
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateDirection(to: coordinate).toDegrees()
    }
    /// Calculates the bearing to another location in radians.
    func bearingToLocationRadian(_ destinationLocation: CLLocationCoordinate2D) -> Double {
        // Reuses the bearing calculation logic for CLLocationCoordinate2D.

        let lat1 = latitude.toRadians()
        let lon1 = longitude.toRadians()
        let lat2 = destinationLocation.latitude.toRadians()
        let lon2 = destinationLocation.longitude.toRadians()

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        return atan2(y, x)
    }

    /// Calculates a new coordinate at a given distance and bearing.
    func coordinate(with bearing: Double, and distance: Double) -> CLLocationCoordinate2D {
        // Projects a coordinate in a specified direction and distance.
        let distRadiansLat = distance / 6373000.0  // earth radius in meters latitude
        let distRadiansLong = distance / 5602900.0 // earth radius in meters longitude
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))
        return CLLocationCoordinate2D(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }

    /// Generates intermediary locations between two points at fixed intervals.
    static func getIntermediaryLocations(currentLocation: CLLocation, destinationLocation: CLLocation) -> [CLLocationCoordinate2D] {
        // Useful for plotting a path or series of waypoints.
        var waypoints = [CLLocationCoordinate2D]()
        let interval: Float = 10 // meters
        var distance = Float(destinationLocation.distance(from: currentLocation))
        let bearing = currentLocation.bearingToLocationRadian(destinationLocation)
        while distance > 10 {
            distance -= interval
            let newLocation = currentLocation.coordinate.coordinate(with: Double(bearing), and: Double(distance))
            if !waypoints.contains(newLocation) {
                waypoints.append(newLocation)
            }
        }
        return waypoints
    }
}
