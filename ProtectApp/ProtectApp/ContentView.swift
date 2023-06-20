//
//  ContentView.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 26.11.22..
//
import SwiftUI
struct ContentView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    var body: some View{
        
            switch viewModel.state {
            case .signedIn:TabView {
                HomeView()
                    .tabItem{
                        Image(systemName: "person.fill").renderingMode(.original)
                        Text("Profile")
                    }
                MapWithUserLocation()
                    .tabItem{
                        Image(systemName: "mappin").renderingMode(.original)
                        Text("Location")
                    }
            }//HomeView()
            case .signedOut: LoginView()
            }
        
        

    }
}
