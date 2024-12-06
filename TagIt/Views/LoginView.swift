//
//  LoginView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

/**
 The LoginView provides a user interface for logging in. It includes fields for the email and password,
 a "Forgot Password" link, and a "Login" button. It also includes navigation to the registration and password recovery views.
 */
struct LoginView: View {
    @StateObject var viewModel = LoginViewModel() // View model to handle login logic

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green // Background color for the login view
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Dismiss the keyboard when tapping outside the text fields
                        UIApplication.shared.hideKeyboard()
                    }
                VStack {
                    Spacer()
                    // Logo icon displayed at the top of the view
                    Image(systemName: "tag.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.leading, 16)
                        .foregroundStyle(.white)

                    // Welcome text
                    Text("Welcome to Tagit")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .font(.system(size: 40))

                    VStack(spacing: 20) {
                        // Email input field
                        TextField("Email", text: $viewModel.email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)

                        // Password input field
                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)
                            .autocapitalization(.none)
                    }.padding(.top, 30)

                    // Forgot password link
                    NavigationLink(destination: PasswordRecoveryView()) {
                        Text("Forgot Password?")
                            .foregroundStyle(.white)
                            .underline()
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .padding(.top, 10)
                    }

                    // Display error message if there is any
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Login button
                    Button(action: {
                        viewModel.login() // Call the login function in the view model
                    }) {
                        if viewModel.isLoading {
                            ProgressView() // Show a loading spinner while logging in
                        } else {
                            Text("Login")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                                .background(.white)
                                .foregroundColor(.green)
                                .cornerRadius(25)
                        }
                    }.padding(.top, 20)

                    // Navigation to RegisterView
                    HStack {
                        Text("New here?")
                            .foregroundStyle(.white)
                        NavigationLink(destination: RegisterView()) {
                            Text("Click here to join us!")
                                .foregroundStyle(.white)
                                .underline()
                        }
                    }.padding(.top, 30)

                    Spacer() // Push the elements towards the top of the screen
                }
            }
        }
        .tint(.white) // Set the default tint color to white
    }
}

#Preview {
    LoginView() // Preview the LoginView
}
