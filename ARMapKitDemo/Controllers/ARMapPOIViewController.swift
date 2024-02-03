//
//  ARMapPOIViewController.swift
//  ARMapKitDemo
//
//  Created by Sandeep on 03/02/24.
//

import Foundation
import MapKit
import ARKit

class ARMapPOIViewController: UIViewController {
    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var arView: ARSCNView!

    // Location manager for handling user location
    let locationManager = LocationManager()

    // Arrays to store annotations and location nodes
    var annotations: [BusinessPOI] = []
    var localSearch: MKLocalSearch?
    var locationAnnotationNodes: [LocationAnnotationNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup delegates and initial configurations for mapView and arView
        mapView.delegate = self
        mapView.showsUserLocation = true


        arView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)

        // Request location permissions from the user
        locationManager.delegate = self

        // Add gesture recognizer for interactions in AR view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sceneLocationViewTouched(_:)))
        self.arView.addGestureRecognizer(tapGesture)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Begin updating the user's location and handle permissions
        locationManager.startUpdatingLocation { [weak self] in
            self?.showLocationDeniedAlert()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Clean up: pause AR session and stop location updates when leaving the view
        if isMovingFromParent || isBeingDismissed {
            arView.session.pause()
            locationManager.stopUpdatingLocation()

        }
    }
}
// MARK: - Helper Methods
extension ARMapPOIViewController {
    // Remove all annotations from the map view
    func removeAnnotations() {
        mapView.removeAnnotations(annotations)
        annotations = []
    }

    // Add annotations to the map view
    func addAnnotations(_ items: [BusinessPOI]) {
        removeAnnotations() // Clear existing annotations before adding new ones
        mapView.addAnnotations(items)
        annotations = items
    }

    // Present an alert for interacting with AR nodes, providing options to the user
    func showARNodeAlert(for locationNode: LocationAnnotationNode) {
        let businessPOI = locationNode.businessPOI!
        let alertController = UIAlertController(title: businessPOI.title, message: businessPOI.subtitle, preferredStyle: .alert)

        // Allow users to remove an AR object directly from the AR view
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeARObject(locationNode)
        }

        alertController.addAction(removeAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alertController, animated: true)
    }

    // Add an AR object to the scene based on a BusinessPOI
    func addARObject(_ item: BusinessPOI) {
        // Ensure AR session is ready and user location is available before adding AR object
        guard arView.session.currentFrame?.camera.trackingState == .normal, let originLocation = locationManager.userLocation else {
            return
        }

        // Avoid adding duplicate AR objects for the same business
        if locationAnnotationNodes.contains(where: { $0.businessPOI == item }) {
            return
        }

        // Create an AR object and position it based on the real-world location
        let labeledView = UIView.prettyLabeledView(text: item.title ?? "N/A")
        let baseNode = LocationAnnotationNode(businessPOI: item, view: labeledView)
        let translation = MatrixHelper.transformMatrix(for: matrix_identity_float4x4, originLocation: originLocation, location: item.location)

        let position = SCNVector3.positionFromTransform(translation)
        let distance = item.location.distance(from: originLocation)
        // Adjust scale based on distance to maintain consistent size perception
        let scale = 100 / Float(distance)
        baseNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        baseNode.anchor = ARAnchor(transform: translation)
        baseNode.position = position

        arView.scene.rootNode.addChildNode(baseNode)
        locationAnnotationNodes.append(baseNode)
    }
    // Remove an AR object from the scene
    func removeARObject(_ locationNode: LocationAnnotationNode) {
        locationNode.removeFromParentNode()
        locationAnnotationNodes.removeAll(where: {$0.businessPOI == locationNode.businessPOI})
    }
    // Display an alert when location access is denied by the user
    func showLocationDeniedAlert() {
        let alertController = UIAlertController(title: "Location access is disabled", message: "You have denied location access on your device. To enable location access visit your application settings.", preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { _ in
            // Direct user to app settings to enable location services
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            guard UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        alertController.addAction(settingsAction)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alertController, animated: true)
    }

    // Update map view to center on the user's current location
    func updateMapUI(coordinate: CLLocationCoordinate2D) {
        // Center the map on the user's location and adjust the zoom level
        self.mapView.setCenter(coordinate, animated: true)
        let coordinateRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000, // Adjust for desired zoom level
            longitudinalMeters: 1000
        )

        self.mapView.setRegion(coordinateRegion, animated: true)
    }
}
// MARK: - Gesture Recognizer for AR Interaction
extension ARMapPOIViewController {
    @objc func sceneLocationViewTouched(_ sender: UITapGestureRecognizer) {
        // Handle tap gestures in the AR view to interact with AR objects
        guard let touchedView = sender.view as? SCNView else { return }

        let coordinates = sender.location(in: touchedView)
        let hitTests = touchedView.hitTest(coordinates)

        // Identify the tapped AR object and present options for interaction
        guard let firstHitTest = hitTests.first, let locationNode = firstHitTest.node.parent as? LocationAnnotationNode else {
            return
        }
        showARNodeAlert(for: locationNode)
    }
}
// MARK: - LocationManagerDelegate
extension ARMapPOIViewController: LocationManagerDelegate {
    func didUpdateUserLocation(_ locationManager: LocationManager, location: CLLocation) {
        DispatchQueue.main.async {
            self.updateMapUI(coordinate: location.coordinate)
            self.performLocalSearch()
        }
    }

    func didUpdateReloadLocation(_ locationManager: LocationManager, location: CLLocation) {
        DispatchQueue.main.async {
            self.updateMapUI(coordinate: location.coordinate)
            self.removeAnnotations()
            self.performLocalSearch()
        }
    }
}
// MARK: - MKMapViewDelegate
extension ARMapPOIViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "business_poi"

        if annotation is BusinessPOI {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let annotationView = MKMarkerAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                annotationView.isEnabled = true
                annotationView.canShowCallout = true

                let btn = UIButton(type: .contactAdd)
                annotationView.rightCalloutAccessoryView = btn
                return annotationView
            }
        }

        return nil
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let businessPOI = view.annotation as? BusinessPOI else { return }
        addARObject(businessPOI)
        mapView.deselectAnnotation(businessPOI, animated: true)
    }
}

// MARK: - ARSCNViewDelegate
extension ARMapPOIViewController: ARSCNViewDelegate {

}


// MARK: - MK Search API
extension ARMapPOIViewController {

    func performLocalSearch(query: String = "shop") {
        localSearch?.cancel()
        guard let userLocation = locationManager.userLocation else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)

        // Perform the search
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            guard let self =  self else { return }
            if let error = error {
                print("Local search error: \(error.localizedDescription)")
                return
            }
            guard let mapItems = response?.mapItems, !mapItems.isEmpty else { return }
            let items = mapItems.compactMap({BusinessPOI(item: $0)})
            DispatchQueue.main.async {
                self.addAnnotations(items)
            }
        }
        localSearch = search
    }
}
