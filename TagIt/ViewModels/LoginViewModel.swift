//
//  LoginViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage = ""
        
        init() {
           
        }
        
        func login(){
            guard validate() else{
                return
            }
            
            // try log in
            Auth.auth().signIn(withEmail: email, password: password)
        }
        
        private func validate() -> Bool{
            errorMessage = ""
            guard !email.trimmingCharacters(in:.whitespaces).isEmpty,
                    !password.trimmingCharacters(in: .whitespaces).isEmpty
            else{
                errorMessage = "Please fill in all fields"
                return false
            }
            
            // email@foo.com
            guard email.contains("@") && email.contains(".") else{
                errorMessage = "Please enter valid email."
                return false
            }
            
            return true
        }
}
