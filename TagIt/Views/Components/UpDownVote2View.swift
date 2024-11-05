//
//  UpDownVote2View.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-31.
//

import SwiftUI

struct UpDownVote2View: View {
    let type: Vote.ItemType
    let id: String
    let upVote, downVote: Int
    @State var showUpVote: Int
    @State var showDownVote: Int
    
    init(type: Vote.ItemType, id: String, upVote: Int, downVote: Int) {
        self.type = type
        self.id = id
        self.upVote = upVote
        self.downVote = downVote
        
        showUpVote = upVote
        showDownVote = downVote
    }

    var body: some View {
        HStack {
            Button(action: {
                print("Thumbsup Tapped")

                if (showUpVote == upVote + 1) {
                    showUpVote = upVote
                } else {
                    showUpVote = upVote + 1
                }
                
                showDownVote = downVote
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.green)
                        .frame(width: 100, height: 30)
                    
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundStyle(Color.white)
                        
                        Text("\(showUpVote)")
                            .padding(.horizontal)
                            .foregroundColor(.white)
                    }
                    
                }
            }
            
            Button(action: {
                print("Thumbsdown Tapped")

                if (showDownVote == downVote + 1) {
                    showDownVote = downVote
                } else {
                    showDownVote = downVote + 1
                }
                
                showUpVote = upVote
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.red)
                        .frame(width: 100, height: 30)
                    
                    HStack {
                        Image(systemName: "hand.thumbsdown.fill")
                            .foregroundStyle(Color.white)
                        
                        Text("\(showDownVote)")
                            .padding(.horizontal)
                            .foregroundColor(.white)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    UpDownVote2View(type: .deal, id: "", upVote: 10, downVote: 20)
}
