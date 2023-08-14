import SwiftUI
import GoogleSignIn


struct HomeView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    private let user = GIDSignIn.sharedInstance.currentUser
    @State private var protectorEmail = ""
    @State private var setAlarm = ""
    @State private var protectorId = ""
    @State private var currentDate = Date()
    
    
    @State private var IsPresentingDistanceMessage = false
    @State private var isPresentingAlarmMessage = false
    
    
    var body: some View {

        NavigationView {
            VStack(alignment: .center) {
                Spacer()
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
                        
                        HStack(spacing: 0) {
                                DatePicker("", selection: $currentDate, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .frame(width: (UIScreen.main.bounds.width / 3) - 20 )
                                
                                Button(action: {
                                    viewModel.saveProtectorAlarm(alarm: currentDate)
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
                        .background(Color(red: 0.0196078431372549, green: 0.11372549019607843, blue: 0.25098039215686274))
                        .cornerRadius(12)
                        .padding()
                }
            }
            .padding(/*@START_MENU_TOKEN@*/.horizontal/*@END_MENU_TOKEN@*/, 20)
            .navigationBarTitle("**ProtectApp**", displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadUserInfo()
        }
        
        .onChange(of: viewModel.distanceFromProtectedUser) { distance in
                    if distance >= 10000 {
                        IsPresentingDistanceMessage = true
                    } else {
                        IsPresentingDistanceMessage = false
                    }
                }
                .sheet(isPresented: $IsPresentingDistanceMessage) {
                    DistanceMessage(distance: viewModel.distanceFromProtectedUser, viewModel: viewModel, IsPresentingDistanceMessage: $IsPresentingDistanceMessage)
                }
        
                .onChange(of: viewModel.showAlert) { showAlert in
                    isPresentingAlarmMessage = showAlert
                }
                .sheet(isPresented: $isPresentingAlarmMessage) {
                    AlarmTimeMessage(viewModel: viewModel, IsPresentingDistanceMessage: $isPresentingAlarmMessage)
                }

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
