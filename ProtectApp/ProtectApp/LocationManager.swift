import Foundation
import CoreLocation
import MapKit
import SwiftUI
import UserNotifications

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
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            } else if granted {
                //print("Notification permission granted")
            } else {
                //print("Notification permission denied")
            }
        }
    }
    
    private func sendNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Protect App"
        content.body = message
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.location = location
            let viewModel = AuthenticationViewModel()
            viewModel.checkDistanceFromProtectedUser(selectedLocation : viewModel.selectedLocation,currentLocation: location, locations: viewModel.locations)

        }
    }

    
    private func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTime = dateFormatter.string(from: Date())
        return currentTime
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
