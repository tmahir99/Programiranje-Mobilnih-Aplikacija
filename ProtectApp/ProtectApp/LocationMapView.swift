import SwiftUI
import MapKit

struct LocationMapView: View {
    @Binding var coordinateRegion: MKCoordinateRegion
    @ObservedObject var viewModel: AuthenticationViewModel
    var locations: [Location]

    @State private var selectedLocation: Location?
    @State private var isPresentingLocationDetails = false

    var body: some View {
        Map(coordinateRegion: $coordinateRegion, annotationItems: locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Button(action: {
                    selectedLocation = location
                    isPresentingLocationDetails = true
                }) {
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(item: $selectedLocation) { location in
            LocationDetailsView(location: location, viewModel: viewModel, isPresentingLocationDetails: $isPresentingLocationDetails)
        }
    }
}

struct LocationDetailsView: View {
    let location: Location
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var isPresentingLocationDetails: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Location Details")
                .font(.title)
            
            Text("Latitude: \(location.coordinate.latitude)")
            Text("Longitude: \(location.coordinate.longitude)")
            Text("The user: \(viewModel.protectingName) was here at \(location.timestamp)")
            
            Spacer()
            
            Button("Close") {
                isPresentingLocationDetails = false
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}
