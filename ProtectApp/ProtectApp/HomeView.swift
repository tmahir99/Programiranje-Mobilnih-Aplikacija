import SwiftUI
import GoogleSignIn
import MapKit


struct HomeView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    private let user = GIDSignIn.sharedInstance.currentUser
    @State private var protectorEmail = ""
    @State private var setAlarm = ""
    @State private var protectorId = ""
    @State private var currentDate = Date()
    
    @State var isShowingSheetSettings = false
    
    @State var isShowingSheet = false
    @State var isShowingSheetLocation = false
    @State var isShowingSheetButton = false

    @State var isShowingSheetAlarm = false
    
    @State private var IsPresentingDistanceMessage = false
    @State private var isPresentingAlarmMessage = false
    
    
    @State private var selectedLocation: CLLocationCoordinate2D?
    
    @StateObject private var viewModel2 = AuthenticationViewModel()
    
    let locationManager = LocationManager()
    
    
    
    
    @State var isShowingSheetPicker = false
    @State private var selectedValue: Double = 500

    
    var body: some View {

        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    NetworkImage(url: user?.profile?.imageURL(withDimension: 200))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text(user?.profile?.name ?? "")
                            .font(.headline)
                            .foregroundColor(Color.white)
                        
                        Text(user?.profile?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.0196078431372549, green: 0.11372549019607843, blue: 0.25098039215686274))
                .cornerRadius(12)
                
                Spacer()
                
                if viewModel.userType == .protecting {
                    if viewModel.protectingEmail == "noone"{
                        VStack(alignment: .leading) {
                            Text("Protector Email")
                                .font(.headline)
        
                            TextField("Enter protector's email", text: $protectorEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
        
                            Text("Protector ID")
                                .font(.headline)
        
                            TextField("Enter protector's ID", text: $protectorId)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.saveProtectorId(email: protectorEmail, protectorId: protectorId, currentUser: user!)
                            }) {
                                Text("Save Protector ID")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemIndigo))
                                    .cornerRadius(12)
                                    .padding()
                            }
                            
                                    .padding()
                        }
                    }
                    else{
                        Text("You are currently protecting: **\(viewModel.protectingName)** , **\(viewModel.protectingEmail)**")
                            .multilineTextAlignment(.leading)
                        Spacer()
                        
                        Button("Security settings!") {
                            isShowingSheetSettings = true
                        }.foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemIndigo))
                        .cornerRadius(12)
                        .padding()
                        .sheet(isPresented: $isShowingSheetSettings) {
                            NavigationView {
                                VStack {
                                    // Set the alarm sheet
                                    Button("Set the alarm!") {
                                        isShowingSheetButton = true
                                    }.foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemIndigo))
                                    .cornerRadius(12)
                                    .padding()
                                    .sheet(isPresented: $isShowingSheetButton) {
                                        NavigationView {
                                            ZStack {
                                                HStack(spacing: 0) {
                                                    DatePicker("", selection: $currentDate, displayedComponents: .hourAndMinute)
                                                        .labelsHidden()
                                                        .frame(width: (UIScreen.main.bounds.width / 3) - 20 )
                                                    
                                                    Button(action: {
                                                        // viewModel.saveProtectorAlarm(alarm: currentDate) // Uncomment this line if needed
                                                    }) {
                                                        Text("Adjust the Alarm")
                                                            .foregroundColor(.white)
                                                            .padding()
                                                            .frame(maxWidth: .infinity)
                                                            .background(Color(.systemIndigo))
                                                            .cornerRadius(12)
                                                    }
                                                    .frame(width: (2 * UIScreen.main.bounds.width / 3) - 50 )
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                            .navigationBarTitle("Set the Alarm", displayMode: .inline)
                                            .navigationBarItems(
                                                trailing:
                                                    Button(action: {
                                                        isShowingSheetButton = false
                                                    }) {
                                                        Text("Done")
                                                    }
                                            )
                                        }
                                    }
                                    
                                    // Set the tracking location sheet
                                    Button("Set the tracking location!") {
                                        isShowingSheetLocation = true
                                    }.foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemIndigo))
                                    .cornerRadius(12)
                                    .padding()
                                    .sheet(isPresented: $isShowingSheetLocation){
                                        LocationPicker(selectedLocation: $viewModel.selectedLocation, isPresented: $isShowingSheetLocation,viewModel: viewModel, locationManager: locationManager)
                                    }
                                    
                                    // Set the alarm range sheet
                                    Button("Alarm range") {
                                        isShowingSheetPicker = true
                                    }.foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemIndigo))
                                    .cornerRadius(12)
                                    .padding()
                                    .sheet(isPresented: $isShowingSheetPicker) {
                                        NavigationView {
                                            ZStack {
                                                HStack(spacing: 0) {
                                                    Text("Selected Value: \(Int(selectedValue)) meters")
                                                    Slider(value: $selectedValue, in: 500...10000, step: 50)
                                                        .padding()
                                                }
                                                .padding(.horizontal, 20)
                                            }
                                            .padding(.horizontal, 20)
                                            .navigationBarTitle("Select Alarm range", displayMode: .inline)
                                            .navigationBarItems(
                                                trailing:
                                                    Button(action: {
                                                        isShowingSheetPicker = false
                                                    }) {
                                                        Text("Done")
                                                    }
                                            )
                                        }
                                    }
                                }
                                .navigationBarTitle("Security Settings", displayMode: .inline)
                                .navigationBarItems(
                                    trailing:
                                        Button(action: {
                                            isShowingSheetSettings = false
                                        }) {
                                            Text("Done")
                                        }
                                )
                            }
                        
                    }

                                //.presentationDetents([.large, .fraction(0.8)])
                                if viewModel.distanceFromProtectedUser != 0{
                                    if Int(viewModel.distanceFromProtectedUser) >= Int(selectedValue){
                                        Text("Current distance from the pin on the map is: **\(String(format: "%.1f", viewModel.distanceFromProtectedUser))**  meter's")
                                            .foregroundColor(.red)
                                            .multilineTextAlignment(.center)
                                    }else{
                                        Text("Current distance from the pin on the map is: **\(String(format: "%.1f", viewModel.distanceFromProtectedUser))**  meter's")
                                            .foregroundColor(.green)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                
                                //Spacer()
                                
                                
                                
                                //                        {
                                //
                                //                                VStack {
                                //                                            Text("Selected Value: \(Int(selectedValue))") // Display the selected value as an integer
                                //
                                //                                            Slider(value: $selectedValue, in: 500...10000, step: 50)
                                //                                                .padding()
                                //                                        }
                                //
                                //                            }

                    }

                } else if viewModel.userType == .protected {
                    VStack(alignment: .leading) {
                        
                        if viewModel.protectorName == "noone"{
                            Text("Please give this code to your protector: \(viewModel.protectorID)")
                                .font(.headline)
                        }
                        else{
                            
                            Text("You are protrcted by : \(viewModel.protectorName)")
                                .font(.headline)
                            
                            if viewModel.alarmStatus == "0"{
                                
                                Text("There is no alarm set for you!")
                                    .font(.headline)
                            }
                            else{
                                Text("You should be home before : \(viewModel.alarmStatus)")
                                    .font(.headline)
                            }
                        }

                    }
                    .padding()
                } else {
                    VStack(alignment: .leading) {
                        Text("Choose User Type")
                            .font(.headline)
                        
                        Button(action: {
                            viewModel.chooseProtector()
                        }) {
                            Text("I want to be a Protector")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemIndigo))
                                .cornerRadius(12)
                                .padding()
                        }
                        
                        Button(action: {
                            viewModel.chooseProtected()
                        }) {
                            Text("I want to be Protected")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemIndigo))
                                .cornerRadius(12)
                                .padding()
                        }
                    }
                    .padding()
                }

                Spacer()
                
                Button(action: viewModel.signOut) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemIndigo))
                        .cornerRadius(12)
                        .padding()
                }
            }
            .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/, 20)
            .navigationBarTitle("ProtectApp")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadUserInfo()
        }
        
        .onChange(of: viewModel.distanceFromProtectedUser) { distance in
                    if distance >= selectedValue {
                        isShowingSheet = true
                    } else {
                        isShowingSheet = false
                    }   
                }
        .sheet(isPresented: $isShowingSheet) {
            ZStack {
                Color(red: 0.86, green: 0.86, blue: 0.86)
                Text("The user: **\(viewModel.protectingName)** is **\(String(format: "%.1f", viewModel.distanceFromProtectedUser / 1000))** KM away from you \n\n\n Please be aware that the user you are protecting is currently to far away from you!")
                    .font(.title)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
            }
            .presentationDetents([.medium, .fraction(0.6)])
        }
        
                .onChange(of: viewModel.showAlert) { showAlert in
                    isPresentingAlarmMessage = showAlert
                    isShowingSheetAlarm = true
                }
                .sheet(isPresented: $isShowingSheetAlarm) {
                        ZStack {
                            Color(red: 0.86, green: 0.86, blue: 0.86)
                            Text("**Alarm is set to \(viewModel.alarmStatus)** \n Time to go home.")
                                .multilineTextAlignment(.center)
                        }
                        .presentationDetents([.medium, .fraction(0.4)])
                    }
//                .sheet(isPresented: $isPresentingAlarmMessage) {
//                    AlarmTimeMessage(viewModel: viewModel, IsPresentingDistanceMessage: $isPresentingAlarmMessage)
//                }
        
        
//        Button("Show the sheet!") {
//            isShowingSheet = true
//        }
//        .sheet(isPresented: $isShowingSheet) {
//            ZStack {
//                Text("This is my sheet. It could be a whole view, or just a text.")
//                    .multilineTextAlignment(.center)
//            }
//            .presentationDetents([.medium, .fraction(0.4)])
//        }

    }
    
}

struct NetworkImage: View {
    let url: URL?

    var body: some View {
        if let url = url,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}


struct DistanceMessage: View {
    let distance: Double
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var IsPresentingDistanceMessage: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("The user: **\(viewModel.protectingName)** is **\(String(format: "%.1f", distance / 1000))** KM away from you")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text("Please be aware that the user you are protecting is currently to far away from you!")
                .font(.body)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Close") {
                IsPresentingDistanceMessage = false
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}


struct AlarmTimeMessage: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Binding var IsPresentingDistanceMessage: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("time to go home, the alarm is set to :")
                .font(.title)
                .fontWeight(.bold)
            Text("\(viewModel.alarmStatus)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(hue: 1.0, saturation: 0.665, brightness: 0.935))
                
            
            Text("Please be aware that it's time to go home!")
                .font(.body)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            
            Spacer()
            
            Button("Close") {
                IsPresentingDistanceMessage = false
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
    }
}


struct LocationPicker: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: AuthenticationViewModel
    var locationManager: LocationManager // Include the locationManager as a property
    
    init(selectedLocation: Binding<CLLocationCoordinate2D?>, isPresented: Binding<Bool>, viewModel: AuthenticationViewModel, locationManager: LocationManager) {
        self._selectedLocation = selectedLocation
        self._isPresented = isPresented
        self.viewModel = viewModel
        self.locationManager = locationManager // Initialize the locationManager property
    }
    
    var body: some View {
        NavigationView {
            MapView(selectedLocation: $viewModel.selectedLocation, locationManager: locationManager)
                .navigationBarTitle("Select Location")
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Done")
                        }
                )
        }
    }
}



struct MapView: UIViewRepresentable {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @ObservedObject var locationManager: LocationManager // Use the LocationManager as an observed object
    @State private var region: MKCoordinateRegion
    
    init(selectedLocation: Binding<CLLocationCoordinate2D?>, locationManager: LocationManager) {
        self._selectedLocation = selectedLocation
        self.locationManager = locationManager
        
        // Set the initial region based on the LocationManager's location if available
        if let location = locationManager.location {
            self._region = State(initialValue: MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        } else {
            // Provide a default region if the location is not available yet
            self._region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 53.1367, longitude: 80.5123), // Default center
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // If a selected location is available, set the region to it
        if let selectedLocation = selectedLocation {
            mapView.setRegion(MKCoordinateRegion(center: selectedLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
            addPinToMap(location: selectedLocation, mapView: mapView)
        } else if let location = locationManager.location { // If selected location is nil, use the current location
            let coordinate = location.coordinate
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
            addPinToMap(location: coordinate, mapView: mapView)
        } else { // If both selected and current locations are nil, set a default center
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 53.1367, longitude: 80.5123), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: true)
        }
        
        // Add a tap gesture recognizer to the map to capture the selected location
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }

    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
            super.init()
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

            parent.selectedLocation = coordinate
            parent.updatePinOnMap(location: coordinate, mapView: mapView)

            print("Selected Location: \(coordinate.latitude), \(coordinate.longitude)")
        }

    }
    
    func addPinToMap(location: CLLocationCoordinate2D, mapView: MKMapView) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    func updatePinOnMap(location: CLLocationCoordinate2D, mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        addPinToMap(location: location, mapView: mapView)
    }
}

