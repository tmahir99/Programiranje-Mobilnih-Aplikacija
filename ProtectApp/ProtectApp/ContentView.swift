//
//  ContentView.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 26.11.22..
//
import SwiftUI
struct ContentView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocation: Location?
    
    var body: some View {
        switch viewModel.state {
        case .signedIn:
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "person.fill").renderingMode(.original)
                        Text("Profile")
                    }
                MapWithUserLocation(locationManager: locationManager, selectedLocation: $selectedLocation)
                    .tabItem {
                        Image(systemName: "mappin").renderingMode(.original)
                        Text("Location")
                    }
                LocationMapView(locations: authViewModel.locations)
                    .tabItem {
                        Image(systemName: "mappin").renderingMode(.original)
                        Text("Location")
                    }
            }
        case .signedOut:
            LoginView()
        }
    }
}



