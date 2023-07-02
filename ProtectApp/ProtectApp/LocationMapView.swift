//
//  LocationMapView.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 2.7.23..
//
import Foundation
import SwiftUI
import MapKit
import CoreLocation

class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
        stopUpdatingLocation()
    }
}

struct LocationMapView: View {
    @StateObject var viewModel = AuthenticationViewModel()
    @StateObject private var locationManagerDelegate = LocationManagerDelegate()
    @State private var selectedLocation: Location? = nil

    var body: some View {
        VStack {
            MapView(viewModel: viewModel, userLocation: locationManagerDelegate.userLocation, selectedLocation: $selectedLocation)
                .frame(height: 300)

            if let location = selectedLocation {
                CloudyMessageView(location: location, isPresented: $selectedLocation)
            }
        }
        .environmentObject(locationManagerDelegate)
    }
}



struct MapView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    var userLocation: CLLocationCoordinate2D?
    @Binding var selectedLocation: Location?

    @State private var calculatedRegion: MKCoordinateRegion = MKCoordinateRegion()

    var body: some View {
        ZStack{
            Map(coordinateRegion: $calculatedRegion, annotationItems: viewModel.locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Button(action: {
                        selectedLocation = location
                    }) {
                        Image(systemName: location == viewModel.locations.last ? "pin.fill" : "pin")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onAppear {
                updateMapRegion()
            }
            .onChange(of: CLLocation(latitude: userLocation?.latitude ?? 0, longitude: userLocation?.longitude ?? 0)) { _ in
                updateMapRegion()
            }
        }
    }

    private func updateMapRegion() {
        if let userLocation = userLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            calculatedRegion = MKCoordinateRegion(center: userLocation, span: span)
        }
    }
}





struct CloudyMessageView: View {
    let location: Location
    @Binding var isPresented: Location?
    
    var body: some View {
        VStack {
            Text("Location Details")
                .font(.headline)
                .padding(.bottom, 8)
            
            Text("Time: \(formattedDate(from: location.timestamp))")
                .font(.subheadline)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            Button(action: {
                isPresented = nil
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
            .padding(8)
            .offset(x: 10, y: -10),
            alignment: .topTrailing
        )
        .padding()
        .shadow(radius: 5)
    }
    
    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        return formatter.string(from: date)
    }
}
