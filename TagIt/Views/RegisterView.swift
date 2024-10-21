//
//  RegisterView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    var body: some View {
        ZStack{
            Color.green
                .ignoresSafeArea()
            VStack{
                Text("Sign up")
                    .font(.system(size:40))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                VStack(spacing: 20){
                    VStack(alignment:.leading){
                        Text("Email")
                            .padding(.horizontal, 40)
                            .foregroundStyle(.white)
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                    }
                    VStack(alignment:.leading){
                        Text("Username")
                            .padding(.horizontal, 40)
                            .foregroundStyle(.white)
                        TextField("Username", text: $viewModel.username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                    }
                    VStack(alignment: .leading){
                        Text("Password")
                            .padding(.horizontal, 40)
                            .foregroundStyle(.white)
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                    }
                    VStack(alignment:.leading){
                        Text("Confirm Password")
                            .padding(.horizontal, 40)
                            .foregroundStyle(.white)
                        SecureField("ConfirmPassword", text: $viewModel.confirmPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                    }
                }
                Button(action: {
                    print("Register was tapped!")
                    viewModel.register()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    }else{
                        Text("Register")
                            .padding(.horizontal,20)
                            .padding(.vertical, 15)
                            .background(.white)
                            .foregroundColor(.green)
                            .cornerRadius(25)
                    }
                }.padding(.top, 20)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    RegisterView()
}
