import SwiftUI
import GoogleSignIn


struct HomeView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    private let user = GIDSignIn.sharedInstance.currentUser
    @State private var protectorEmail = ""
    @State private var setAlarm = ""
    @State private var protectorId = ""
    @State private var currentDate = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NetworkImage(url: user?.profile?.imageURL(withDimension: 200))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text(user?.profile?.name ?? "")
                            .font(.headline)
                        
                        Text(user?.profile?.email ?? "")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
                
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
                        Text("You are currently protecting: \(viewModel.protectingName)")
                            .font(.headline)
                            .padding()
                        Text("You are currently protecting: \(viewModel.protectingEmail)")
                            .font(.headline)
                            .padding()
                        DatePicker("", selection: $currentDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        Spacer()
                        
                        Button(action: {
                            viewModel.saveProtectorAlarm(alarm: currentDate)
                        }) {
                            Text("Adjust the Alarm")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemIndigo))
                                .cornerRadius(12)
                                .padding()
                        }

                        
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
            .navigationTitle("ProtectApp")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.loadUserInfo()
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
