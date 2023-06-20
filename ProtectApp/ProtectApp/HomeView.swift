import SwiftUI
import GoogleSignIn

struct HomeView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    private let user = GIDSignIn.sharedInstance.currentUser
    @State private var protectorEmail = ""
    @State private var protectorId = ""

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
                }
                .padding()

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
    }
}


/// A generic view that shows images from the network.
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
