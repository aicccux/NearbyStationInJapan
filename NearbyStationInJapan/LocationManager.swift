//
//  LocationManager.swift
//  NearbyStationInJapan
//
//  Created by aicccux on 6/15/24.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion()
    @Published var currentLocation: CLLocation?
    @Published var route: MKRoute?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        let center = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: 1000.0,
            longitudinalMeters: 1000.0
        )
    }
    
    func getRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, transportType: MKDirectionsTransportType) {
        let sourceMark = MKPlacemark(coordinate: from)
        let destinationMark = MKPlacemark(coordinate: to)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourceMark)
        request.destination = MKMapItem(placemark: destinationMark)
        request.transportType = transportType
        let directions = MKDirections(request: request)
        if request.transportType == .transit {
            Task { @MainActor in
                let etaResponse = try await directions.calculateETA()
                let etaSeconds = etaResponse.expectedTravelTime
                _ = Int(etaSeconds / 60)
            }
        } else {
            Task { @MainActor in
                let response = try await directions.calculate()
                let routes = response.routes
                route = routes.first
            }
        }
    }
}
