//
//  UserInfo.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 17.12.22..
//

import SwiftUI
import GoogleSignIn

struct UserInfo: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  
  private var button = GIDSignInButton()

  func makeUIView(context: Context) -> GIDSignInButton {
    button.colorScheme = colorScheme == .dark ? .dark : .light
    return button
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    button.colorScheme = colorScheme == .dark ? .dark : .light
  }
}
