//
//  PasswordRecoveryView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct PasswordRecoveryView: View {
    @StateObject var viewModel = PasswordRecoveryViewModel()
    var body: some View {
        ZStack{
            Color.green.ignoresSafeArea()
            VStack{
                Text("Password Recovery")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding()
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
                }
                Button(action: {
                    print("Button was tapped!")
                }) {
                    
                    Text("Submit")
                        .padding(.horizontal,20)
                        .padding(.vertical, 15)
                        .background(.white)
                        .foregroundColor(.green)
                        .cornerRadius(25)
                }.padding(.top, 20)
                Spacer()
            }
        }
    }
}

#Preview {
    PasswordRecoveryView()
}
