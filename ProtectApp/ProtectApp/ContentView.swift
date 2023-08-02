import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @StateObject private var locationManager = LocationManager()
    @State private var selectedLocation: Location?
    

    @State private var coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.330, longitude: -122.028), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

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
                        Text("Me")
                    }
                if viewModel.userType == .protecting {
                    LocationMapView(coordinateRegion: $coordinateRegion, viewModel: authViewModel, locations: authViewModel.locations)
                        .tabItem {
                            Image(systemName: "mappin").renderingMode(.original)
                            Text("\(viewModel.protectingName)")
                        }
                }
            }
        case .signedOut:
            LoginView()
        }
    }
}
