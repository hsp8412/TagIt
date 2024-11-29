//
//  LoginView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.green
                    .ignoresSafeArea()
                VStack{
                    Spacer()
                    Image(systemName: "tag.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.leading, 16)
                        .foregroundStyle(.white)
                    Text("Welcome to Tagit")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .font(.system(size: 40))
                    
                    VStack(spacing:20){
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                    }.padding(.top, 30)
                    
                    NavigationLink(destination: PasswordRecoveryView()) {
                        Text("Forgot Password?")
                            .foregroundStyle(.white)
                            .underline()
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .padding(.top, 10)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        }
                        else{
                            Text("Login")
                                .padding(.horizontal,20)
                                .padding(.vertical, 15)
                                .background(.white)
                                .foregroundColor(.green)
                                .cornerRadius(25)
                        }
                    }.padding(.top, 20)
                    
                    
                    HStack{
                        Text("New here?")
                            .foregroundStyle(.white)
                        NavigationLink(destination: RegisterView()){
                            Text("Click here to join us!")
                                .foregroundStyle(.white)
                            .underline()}
                    }.padding(.top, 30)
                    Spacer()
                }
            }
        }
        .onTapGesture {
            // Dismiss the keyboard when tapping outside
            UIApplication.shared.hideKeyboard()
        }
        .tint(.white)
    }
}

#Preview {
    LoginView()
}
