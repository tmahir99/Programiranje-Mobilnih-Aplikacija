import Foundation
import CoreLocation
import MapKit
import SwiftUI

final class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    private var locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.location = location
            print("Location", location)
        }
    }
}

extension MKCoordinateRegion {
    static func goldenGateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783), latitudinalMeters: 5000, longitudinalMeters: 5000)
    }

    func getBinding() -> Binding<MKCoordinateRegion>? {
        Binding<MKCoordinateRegion>(.constant(self))
    }
}
