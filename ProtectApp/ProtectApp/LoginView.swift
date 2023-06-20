//
//  LoginView.swift
//  ProtectApp
//
//  Created by Mahir Tahirovic on 23.12.22..
//

import SwiftUI

struct LoginView: View {

  // 1
  @EnvironmentObject var viewModel: AuthenticationViewModel

  var body: some View {
    VStack {
      Spacer()

      // 2
      Image("Childprotect")
        .resizable()
        .clipShape(Circle())
        .frame(width: 100, height: 100, alignment: .center)

      Text("Welcome to ProtectApp!")
        .fontWeight(.black)
        .font(.largeTitle)
        .foregroundColor(Color(red: 0.0196078431372549, green: 0.11372549019607843, blue: 0.25098039215686274))
        .multilineTextAlignment(.center)

      Text("Protecting was never izijer")
            .fontWeight(.bold)
        .multilineTextAlignment(.center)
        .padding()

      Spacer()

      // 3
      UserInfo()
        .padding()
        .onTapGesture {
          viewModel.signIn()
        }
    }
  }
}
