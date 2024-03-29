import Firebase
import CoreLocation
import FirebaseDatabase
import GoogleSignIn
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    enum UserType {
        case protecting
        case protected
        case none
    }
    
    @Published var state: SignInState = .signedOut
    let locationManager = LocationManager()
    
    private var timer: Timer?
    private var userId: String?
    
    
    @Published var userType: UserType = .none
    @Published var protectorName: String = ""
    @Published var protectorID: String = ""
    @Published var alarmStatus: String = "0"
    @Published var protectingEmail : String = ""
    @Published var protectingName : String = ""
    @Published var locations: [Location] = []
    @Published var locations1: [Location] = []
    @Published var distanceFromProtectedUser : Double = 0;
    
    @Published var selectedLocation: CLLocationCoordinate2D?
    
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()

        do {
            try Auth.auth().signOut()

            state = .signedOut
            timer?.invalidate()
            timer = nil
            userId = nil
            userType = .none
            protectorName = ""
            protectorID = ""
            alarmStatus = ""
            protectingEmail = ""
            protectorName = ""
            locations = []
        } catch {
            print(error.localizedDescription)
        }
    }
    
    enum SignInState {
        case signedIn
        case signedOut
    }


    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            loadUserInfo()

            let configuration = GIDConfiguration(clientID: clientID)

            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            GIDSignIn.sharedInstance.signIn(with: configuration, presenting: rootViewController) { [unowned self] user, error in
                authenticateUser(for: user, with: error)

                self.userId = user?.profile?.email.replacingOccurrences(of: ".", with: "=")

                if let userId = self.userId {
                    let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
                    let userRef = ref.child("users").child(userId)
                    userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                        if !snapshot.exists() {
                            self?.createUserEntry(userId: userId, user: user)
                        } else {
                            self?.startLocationUpdates(userId: userId)
                        }
                    }
                }
            }
        }
    }
    
    func loadUserInfo() {
        guard let userEmail = Auth.auth().currentUser?.email?.replacingOccurrences(of: ".", with: "=") else { return }
        let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
        let usersRef = ref.child("users")
        
        usersRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.hasChild(userEmail) {
                let userRef = usersRef.child(userEmail)
                
                userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                    if snapshot.exists() {
                        if let userDataDict = snapshot.value as? [String: Any] {
                           // print("User Data Dictionary: \(userDataDict)")
                            if let userType = userDataDict["UserType"] as? String {
                                if userType == "protecting" {
                                    self?.userType = .protecting
                                    self?.protectingEmail = "\(userDataDict["protectingEmail"] ?? "")"
                                    self?.protectingName = "\(userDataDict["protectingName"] ?? "")"
                                    
                                    if let protectorEmail = userDataDict["protectingEmail"] as? String {
                                        self?.fetchProtectorLocations(protectorEmail: protectorEmail)
                                    }
                                } else if userType == "protected" {
                                    self?.userType = .protected
                                    self?.protectorName = "\(userDataDict["protectorName"] ?? "")"
                                    self?.protectorID = "\(userDataDict["id"] ?? "")"
                                    self?.alarmStatus = "\(userDataDict["alarm"] ?? "0")"
                                    self?.locations = []
                                    
                                    if let locationString = userDataDict["locations"] as? String {
                                        //print("Location String: \(locationString)")
                                        
                                        if let data = locationString.data(using: .utf8),
                                           let locationsArray = try? JSONDecoder().decode([Location].self, from: data) {
                                            self?.locations = locationsArray
                                            
//                                            for location in locationsArray {
//                                                print("Coordinate: \(location.coordinate.latitude), \(location.coordinate.longitude)")
//                                                print("Timestamp: \(location.timestamp)")
//                                            }
                                        } else {
                                            print("Error decoding locations data")
                                        }
                                    } else {
                                        print("No locations data found")
                                    }
                                }
                                else if userType == "NotSelected"{
                                    self?.userType = .none
                                    self?.protectorName = "noone"
                                    self?.alarmStatus = "0"
                                    self?.protectorID = "\(userDataDict["id"] ?? "")"
                                    self?.protectingEmail = "noone"
                                    self?.protectingName = "noone"
                                }
                            }
                        }
                    } else {
                        print("Snapshot does not exist")
                    }
                }
            } else {
                print("User email not found in the database")
            }
        }
    }




    func fetchProtectorLocations(protectorEmail: String) {
        let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
        let usersRef = ref.child("users")
        let protectorEmailKey = protectorEmail.replacingOccurrences(of: ".", with: "=")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy, h:mm a"

        usersRef.child(protectorEmailKey).child("locations").observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists(), let locationsDict = snapshot.value as? [String: Any] {
                var fetchedLocations: [Location] = []

                for (_, locationData) in locationsDict {
                    if let locationDict = locationData as? [String: Any],
                       let latitude = locationDict["latitude"] as? Double,
                       let longitude = locationDict["longitude"] as? Double,
                       let timestampString = locationDict["timestamp"] as? String,
                       let timestamp = dateFormatter.date(from: timestampString) {

                        let location = Location(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), timestamp: timestamp)
                        fetchedLocations.append(location)
                    }
                }

                // Update the locations array
                DispatchQueue.main.async {
                    self?.locations = fetchedLocations
                    //print("\(self?.locations.last) ovde printam kada se tek kao uhvate")
                }
            } else {
                print("No protector locations data found")
            }
        }
    }

    
    func chooseProtector() {
        userType = .protecting
    }
    
    func chooseProtected() {
        userType = .protected
    }
    

    private func createUserEntry(userId: String, user: GIDGoogleUser?) {
        let datas: [String: Any] = [
            "id": randomString(length: 5),
            "name": user?.profile?.givenName,
            "surname": user?.profile?.familyName,
            "protectorEmail": "noone",
            "protectorName": "noone",
            "protectingEmail": "noone",
            "protectingName": "noone",
            "email" : user?.profile?.email,
            "alarm": 0,
            "locations": [:],
            "UserType" : "NotSelected"
        ]

        let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
        let userRef = ref.child("users").child(userId)
        userRef.setValue(datas) { (error, _) in
            if let error = error {
                print("Error creating user entry in Firebase: \(error)")
            } else {
                print("User entry created in Firebase")
                self.startLocationUpdates(userId: userId)
            }
        }
    }


    private func startLocationUpdates(userId: String) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.updateUserLocation(userId: userId)
            if self?.userType == .protected {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let currentTime = dateFormatter.string(from: Date())
                self?.checkAlarmTime(currentTime: currentTime, alarmStatus: self?.alarmStatus ?? "")
            }
            
            //let viewModel = AuthenticationViewModel()
                
            self?.checkDistanceFromProtectedUser(selectedLocation: self?.selectedLocation,currentLocation: self?.locationManager.location, locations: self?.locations ?? [])
        }
        self.timer?.fire()
    }

    func checkDistanceFromProtectedUser(selectedLocation: CLLocationCoordinate2D?, currentLocation: CLLocation?, locations: [Location]) {
        if userType == .protecting, let protectedUserLocation = locations.last {
            let currentCoordinate: CLLocationCoordinate2D
            
            if let selectedLocation = selectedLocation {
                currentCoordinate = selectedLocation
                print("sad je selected location \(currentCoordinate)")
            } else if let currentLocation = currentLocation {
                currentCoordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
                print("sad je current location \(currentCoordinate)")
            } else {
                return // Return early if neither selectedLocation nor currentLocation is available
                
            }
            
            let protectedUserCoordinate = protectedUserLocation.coordinate
            let currentLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            let protectedUserLocation = CLLocation(latitude: protectedUserCoordinate.latitude, longitude: protectedUserCoordinate.longitude)

            let distance = currentLocation.distance(from: protectedUserLocation)
            distanceFromProtectedUser = distance
            print("\(distance/1000) KM away")
            if distance > 10000 {
                print("The user you are protecting is more than 10km away")
            } else {
                print("The user you are protecting is within 10km")
            }
        }
    }

    
    func checkAlarmTime(currentTime: String, alarmStatus: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let currentTimeDate = formatter.date(from: currentTime),
              let alarmTimeDate = formatter.date(from: alarmStatus) else {
            return
        }

        let calendar = Calendar.current
        let comparison = calendar.compare(currentTimeDate, to: alarmTimeDate, toGranularity: .minute)

        switch comparison {
        case .orderedSame:
            
            alertMessage = "Time to go home"
            showAlert = true
        case .orderedDescending:
            
            if !showAlert {
                alertMessage = "You missed the alarm time to go home"
                showAlert = true
            }
        default:
            
            break
        }
    }



    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }

        guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)

        Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.state = .signedIn
            }
        }
    }

    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }

    private func updateUserLocation(userId: String) {
        if let location = locationManager.location {
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
            let locationData: [String: Any] = [
                "timestamp": timestamp,
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude
            ]

            let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
            let locationsRef = ref.child("users").child(userId).child("locations")

            locationsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                if snapshot.exists() {
                    if let locationsDict = snapshot.value as? [String: Any] {
                        let locationCount = locationsDict.count
                        let newLocationKey = "location\(locationCount + 1)"
                        locationsRef.child(newLocationKey).setValue(locationData) { (error, _) in
                            if let error = error {
                                print("Error saving location to Firebase: \(error)")
                            } else {
                                print("Location saved to Firebase")
                            }
                        }
                    }
                } else {
                    let newLocationKey = "location1"
                    locationsRef.child(newLocationKey).setValue(locationData) { (error, _) in
                        if let error = error {
                            print("Error saving location to Firebase: \(error)")
                        } else {
                            print("Location saved to Firebase")
                        }
                    }
                }
            }
        }
    }
    
    func saveProtectorId(email: String, protectorId: String, currentUser: GIDGoogleUser) {
        let modifiedEmail = email.replacingOccurrences(of: ".", with: "=")
        let modifiedEmail2 = currentUser.profile?.email.replacingOccurrences(of: ".", with: "=")
        
        let database = Database.database().reference()
        let usersRef = database.child("users")
        
        usersRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(modifiedEmail) {
                guard let protectorData = snapshot.childSnapshot(forPath: modifiedEmail).value as? [String: Any] else {
                    print("Error: Invalid protector data")
                    return
                }
                
                
                let email = "\(protectorData["email"] ?? "")"
                let currentUserRef = usersRef.child(modifiedEmail2!)
                currentUserRef.updateChildValues([
                    "protectingEmail": email,
                    "protectingName" :  "\(protectorData["name"] ?? "")",
                    "UserType": "protecting",
                    "protector": "noone"])
                
                
                let protectorRef = usersRef.child(modifiedEmail)
                protectorRef.updateChildValues([
                    "protectorEmail": "\(currentUser.profile?.email ?? "")",
                    "UserType": "protected",
                    "protectorName": "\(currentUser.profile?.givenName ?? "")\(currentUser.profile?.familyName ?? "")"])
                
                print("Protector information updated successfully")
            } else {
                print("Protector email not found in the database")
            }
        }
    }


    func saveProtectorAlarm(alarm: Date) {
        let modifiedEmail = protectingEmail.replacingOccurrences(of: ".", with: "=")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let alarmTime = dateFormatter.string(from: alarm)
        
        let database = Database.database().reference()
        let usersRef = database.child("users")
        
        usersRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(modifiedEmail) {
                // Update the protector's information
                let protectorRef = usersRef.child(modifiedEmail)
                protectorRef.updateChildValues([
                    "alarm": "\(alarmTime)"])
                
                print("Protector information updated successfully")
                
                // Show success notification (toast)
                self.showAlert(message: "Alarm set successfully")
                
            } else {
                print("Protector email not found in the database")
                
                // Show error notification (toast)
                self.showAlert(message: "Something went wrong")
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
    }




    
    private func getUserFullName(userId: String) -> String {
        let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
        let userRef = ref.child("users").child(userId)
        
        var fullName = ""
        
        userRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let userDataDict = snapshot.value as? [String: Any] {
                    let firstName = userDataDict["name"] as? String ?? ""
                    let lastName = userDataDict["surname"] as? String ?? ""
                    fullName = "\(firstName) \(lastName)"
                }
            }
        }
        
        return fullName
    }
    
}
class Location: Identifiable, Codable , Equatable{
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
    var timestamp: Date

    init(coordinate: CLLocationCoordinate2D, timestamp: Date) {
        self.coordinate = coordinate
        self.timestamp = timestamp
    }

    private enum CodingKeys: String, CodingKey {
        case coordinate, timestamp
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinateWrapper = try container.decode(Coordinate.self, forKey: .coordinate)
        coordinate = coordinateWrapper.coordinate
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let coordinateWrapper = Coordinate(coordinate: coordinate)
        try container.encode(coordinateWrapper, forKey: .coordinate)
        try container.encode(timestamp, forKey: .timestamp)
    }

    private struct Coordinate: Codable {
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees

        var coordinate: CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        init(coordinate: CLLocationCoordinate2D) {
            latitude = coordinate.latitude
            longitude = coordinate.longitude
        }
    }
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.timestamp == rhs.timestamp
    }
}



