//
//  LoginView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI
import AuthenticationServices

/**
 The LoginView provides a user interface for logging in. It includes fields for the email and password,
 a "Forgot Password" link, and a "Login" button. It also includes navigation to the registration and password recovery views.
 */
struct LoginView: View {
    @StateObject var viewModel = LoginViewModel() // View model to handle login logic
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.cyan]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Fixed header at the top
                    VStack {
                        Image(systemName: "tag.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.leading, 16)
                            .foregroundStyle(.white)

                        Text("Discover. Share. Save.")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    // The header stays put at the top

                    // Scrollable area for fields and buttons
                    ScrollView {
                        VStack(spacing: 10) {
                            // Email field
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                TextField("Email", text: $viewModel.email)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                            .shadow(radius: 5)

                            // Password field with Forgot Password link
                            ZStack {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 30, height: 30)
                                    SecureField("Password", text: $viewModel.password)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                                .shadow(radius: 5)

                                NavigationLink(destination: PasswordRecoveryView()) {
                                    Text("Forgot Password?")
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundStyle(.white)
                                        .underline()
                                        .font(.system(size: 16))
                                        .fontWeight(.light)
                                        .padding(.trailing, 40)
                                        .padding(.top, 90)
                                }
                            }
                            .padding(.top, 20)

                            // Display error if any
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
                                viewModel.login()
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                } else {
                                    Text("Login")
                                        .font(.system(size: 17, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                        .shadow(radius: 5)
                                }
                            }
                            .frame(height: 50)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)

                            // Sign In with Apple Button
                            SignInWithAppleButton(
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                    request.nonce = AuthService.shared.generateAndSetNonce()
                                },
                                onCompletion: { result in
                                    switch result {
                                    case .success(let authorization):
                                        AuthService.shared.signInWithApple(authorization: authorization) { result in
                                            switch result {
                                            case .success(let userId):
                                                print("Successfully signed in with Apple: \(userId)")
                                                viewModel.isLoggedIn = true
                                            case .failure(let error):
                                                viewModel.errorMessage = error.localizedDescription
                                            }
                                        }
                                    case .failure(let error):
                                        viewModel.errorMessage = error.localizedDescription
                                    }
                                }
                            )
                            .signInWithAppleButtonStyle(.black)
                            .frame(height: 50)
                            .padding(.horizontal, 40)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding(.top, 10)

                            HStack {
                                Text("New here?")
                                    .foregroundStyle(.white)
                                NavigationLink(destination: RegisterView()) {
                                    Text("Click here to join us!")
                                        .foregroundStyle(.white)
                                        .underline()
                                }
                            }.padding(.top, 30)

                            Spacer().frame(height: 50)
                        }
                        .padding(.top, 30)
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
            .tint(.white)
        }
    }
}
#Preview {
    LoginView() // Preview the LoginView
}
