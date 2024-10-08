//
//  MainViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import FirebaseAuth
import Foundation

import Foundation
class MainViewModel: ObservableObject{
    @Published var currentUserId:String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    init(){
        self.handler = Auth.auth().addStateDidChangeListener{[weak self]_, user in
            DispatchQueue.main.async{
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }
    
    public var isSignedIn:Bool{
        return Auth.auth().currentUser != nil
    }
}
