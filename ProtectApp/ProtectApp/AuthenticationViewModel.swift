import Firebase
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
    @Published var alarmStatus: Int = 0
    @Published var protectingEmail : String = ""
    
    
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
        guard let userId = self.userId else { return }
        let ref = Database.database(url: "https://protectapp-2023-2-default-rtdb.firebaseio.com").reference()
        let userRef = ref.child("users").child(userId)
        
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists() {
                if let userDataDict = snapshot.value as? [String: Any] {
                    if let userType = userDataDict["UserType"] as? String {
                        if userType == "protecting" {
                            self?.userType = .protecting
                            self?.protectingEmail = "\(userDataDict["protectingEmail"] ?? "")"
                        } else if userType == "protected" {
                            self?.userType = .protected
                            self?.protectorName = "\(userDataDict["protector"] ?? "")"
                            self?.protectorID = "\(userDataDict["id"] ?? "")"
                            self?.alarmStatus = userDataDict["alarm"] as? Int ?? 0
                        }
                    }
                }
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
        }
        self.timer?.fire()
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

    func signOut() {
        GIDSignIn.sharedInstance.signOut()

        do {
            try Auth.auth().signOut()

            state = .signedOut
            timer?.invalidate()
            timer = nil
            userId = nil
            userType = .none
        } catch {
            print(error.localizedDescription)
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
                
                // Update the current user's information
                let email = "\(protectorData["email"] ?? "")"
                let currentUserRef = usersRef.child(modifiedEmail2!) // Use modified email as the key
                currentUserRef.updateChildValues([
                    "protectingEmail": email,
                    "protectingName" :  "\(protectorData["name"] ?? "")",
                    "UserType": "protecting",
                    "protector": "noone"])
                
                // Update the protector's information
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

