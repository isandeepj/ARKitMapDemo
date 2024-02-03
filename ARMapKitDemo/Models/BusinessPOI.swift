//
//  BusinessPOI.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation

import MapKit

class BusinessPOI: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let location: CLLocation
    let placemark: CLPlacemark?

    init(item: MKMapItem) {
        self.title = item.name ?? "N/A"
        self.subtitle = item.placemark.title ?? "N/A"
        self.coordinate = item.placemark.coordinate
        self.placemark = item.placemark
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
 
    static func == (lhs: BusinessPOI, rhs: BusinessPOI) -> Bool {
        return lhs.title == rhs.title && lhs.coordinate == rhs.coordinate
    }

}
