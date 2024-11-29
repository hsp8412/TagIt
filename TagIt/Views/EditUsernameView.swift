//
//  EditUsernameView.swift
//  TagIt
//
//  Created by Angi Shi on 2024-11-19.
//

import SwiftUI

struct EditUsernameView: View {
    @State private var newUsername: String = ""
    
    var body: some View {
        VStack {
            Text("Edit Username")
                .font(.title)
                .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("New Username")
                    .font(.body)
                TextField("Enter new username", text: $newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            Button(action: {
                print("Username updated to: \(newUsername)")
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .background(Color.white // <-- this is also a view
            .onTapGesture { // <-- add tap gesture to it
                UIApplication.shared.hideKeyboard()
            })
    }
}

#Preview {
    EditUsernameView()
}
