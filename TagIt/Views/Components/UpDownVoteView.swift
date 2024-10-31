//
//  UpDownVoteView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-10-31.
//

import SwiftUI

struct UpDownVoteView: View {
    let type: Vote.ItemType
    let id: String
    var upVote, downVote: Int
    @State var showUpVote: Int
    @State var showDownVote: Int
    @State var upVoteTap: Bool
    @State var downVoteTap: Bool
    
    init(type: Vote.ItemType, id: String, upVote: Int, downVote: Int, upVoteTap: Bool, downVoteTap: Bool) {
        self.type = type
        self.id = id
        self.upVote = upVote
        self.downVote = downVote
        self.upVoteTap = upVoteTap
        self.downVoteTap = downVoteTap
        self.showUpVote = upVote
        self.showDownVote = downVote
        
        if (upVoteTap) {
            self.upVote = upVote - 1
    
        }
        
        if (downVoteTap) {
            self.downVote = downVote - 1
        }
    }

    var body: some View {
        HStack {
            Button(action: {
                print("Thumbsup Tapped")

                if (upVoteTap) {
                    showUpVote = upVote
                } else {
                    showUpVote = upVote + 1
                    
                }
                
                showDownVote = downVote
                downVoteTap = false
                
                upVoteTap.toggle()
            }) {
                ZStack {
                    if (upVoteTap) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                            .frame(width: 100, height: 30)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.green, lineWidth: 3)
                            .frame(width: 100, height: 30)
                    }
                    
                    HStack {
                        if (upVoteTap) {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundStyle(Color.white)
                            
                            Text("\(showUpVote)")
                                .padding(.horizontal)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "hand.thumbsup.fill")
                                .foregroundStyle(Color.green)
                            
                            Text("\(showUpVote)")
                                .padding(.horizontal)
                                .foregroundColor(.green)
                        }
                    }
                    
                }
            }
            
            Button(action: {
                print("Thumbsdown Tapped")

                if (downVoteTap) {
                    showDownVote = downVote
                } else {
                    showDownVote = downVote + 1
                }
                
                showUpVote = upVote
                upVoteTap = false

                downVoteTap.toggle()
            }) {
                ZStack {
                    if (downVoteTap) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.red)
                            .frame(width: 100, height: 30)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.red, lineWidth: 3)
                            .frame(width: 100, height: 30)
                    }
                    
                    HStack {
                        if (downVoteTap) {
                            Image(systemName: "hand.thumbsdown.fill")
                                .foregroundStyle(Color.white)
                            
                            Text("\(showDownVote)")
                                .padding(.horizontal)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "hand.thumbsdown.fill")
                                .foregroundStyle(Color.red)
                            
                            Text("\(showDownVote)")
                                .padding(.horizontal)
                                .foregroundColor(.red)
                        }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    UpDownVoteView(type: .comment, id: "", upVote: 10, downVote: 21, upVoteTap: false, downVoteTap: true)
}
