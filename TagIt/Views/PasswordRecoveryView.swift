//
//  PasswordRecoveryView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

/**
 The PasswordRecoveryView allows users to request a password reset by entering their email address.
 The user submits the form, and an email is sent for password recovery.
 */
struct PasswordRecoveryView: View {
    @StateObject var viewModel = PasswordRecoveryViewModel() // ViewModel to handle password recovery logic

    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea() // Background color for the view
            VStack {
                // Title
                Text("Password Recovery")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding()

                // Email input form
                VStack(alignment: .leading) {
                    Text("Email")
                        .padding(.horizontal, 40)
                        .foregroundStyle(.white)
                    TextField("Email", text: $viewModel.email) // User inputs email for recovery
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                        .shadow(radius: 5)
                }

                // Submit button
                Button(action: {
                    print("Button was tapped!") // Placeholder action for now
                }) {
                    Text("Submit")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .background(.white)
                        .foregroundColor(.green)
                        .cornerRadius(25)
                }.padding(.top, 20)

                Spacer() // Spacer to push elements towards the top
            }
        }
    }
}

#Preview {
    PasswordRecoveryView() // Preview the PasswordRecoveryView
}
