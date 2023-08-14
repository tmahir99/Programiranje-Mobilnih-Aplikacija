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
          
          // 2
          Circle()
              .stroke(Color(.systemIndigo), lineWidth: 19) // Adjust the lineWidth as needed
              .frame(width: 103.0, height: 103.0)
              .overlay{
                  Image("Childprotect")
                      .resizable()
                      .clipShape(Circle())
                      .frame(width: 100, height: 100)
              }

          
          Text("Welcome to ProtectApp!")
              .fontWeight(.black)
              .font(.largeTitle)
              .foregroundColor(Color(red: 0.0196078431372549, green: 0.11372549019607843, blue: 0.25098039215686274))
              .multilineTextAlignment(.center)
          
          //      Text("Protecting has never been easier")
          //            .fontWeight(.bold)
          //        .multilineTextAlignment(.center)
          //        .padding()
          
          
          // 3
//          UserInfo()
//              .padding(.horizontal, 80.0)
//              .padding(.top, 30)
//              .onTapGesture {
//                  viewModel.signIn()
//              }
          Button(action: viewModel.signIn) {
              Text("Sign in")
                  .foregroundColor(.white)
                  .multilineTextAlignment(.center)
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(Color(.systemIndigo))
                  .cornerRadius(12)
                  .padding()
          }
          
      }

  }
}
