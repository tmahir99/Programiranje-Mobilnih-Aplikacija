//
//  ProtectAppApp.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 26.11.22..
//

import SwiftUI
import Firebase
import GoogleSignIn



@main
struct ProtectApp: App {
    @StateObject var viewModel = AuthenticationViewModel()
   
    init() {
      setupAuthentication()
    }

    var body: some Scene {
      WindowGroup {
        ContentView()
          .environmentObject(viewModel)
      }
    }
  }

  extension ProtectApp {
    private func setupAuthentication() {
      FirebaseApp.configure()
    }
  }
