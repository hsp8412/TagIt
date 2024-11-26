import SwiftUI
import FirebaseAuth

struct DealInfoView: View {
    @Binding var deal: Deal
    @State var isLoading = true
    @State var isSaved = false
    @State var user: UserProfile?
    @State private var profileErrorMessage: String?
    @State private var voteErrorMessage: String?
    @State private var currentUserId: String? = nil
    @State private var isPhotoExpanded: Bool = false // State to toggle photo expansion

    var body: some View {
        VStack(spacing: 15) {
            Button(action: {
                saveDeal()
                isSaved = true
            }) {
                Text(isSaved ? "Saved" : "Save")
                    .foregroundStyle(.white)
                    .bold()
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.green)
                    .frame(width: 70, height: 30)
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
            
            Divider()
                .background(Color.gray.opacity(0.5))
            
            // Product Image Section
            AsyncImage(url: URL(string: deal.photoURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            isPhotoExpanded = true // Expand the photo on tap
                        }
                } else {
                    ProgressView()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(maxWidth: .infinity)

            Divider()
                .background(Color.gray.opacity(0.5))

            // User Info Section
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if let profileErrorMessage = profileErrorMessage {
                        Text("Error: \(profileErrorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        UserAvatarView(avatarURL: user?.avatarURL ?? "")
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user?.displayName ?? "Unknown User")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Text(deal.date)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                }

                // Product Details Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(deal.productText)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text(String(format: "$%.2f", deal.price))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                }

                // Post Text
                Text("\"\(deal.postText)\"")
                    .italic()
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Location and Voting Section
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin")
                            .foregroundColor(.green)
                        Text(deal.location)
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                  
                    Spacer()
                    
                    if let userId = currentUserId {
                        UpDownVoteView(
                            userId: userId,
                            type: .deal,
                            id: deal.id!,
                            upVote: $deal.upvote,
                            downVote: $deal.downvote
                        )
                    } else {
                        ProgressView()
                            .onAppear {
                                fetchCurrentUserId()
                            }
                    }
                }
            }
        }
        .padding(15)
        .background(
            Color.white
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .onAppear {
            fetchUserProfile()
        }
        .fullScreenCover(isPresented: $isPhotoExpanded) {
            PhotoFullScreenView(imageURL: deal.photoURL, isPresented: $isPhotoExpanded)
        }
    }

    struct PhotoFullScreenView: View {
        let imageURL: String
        @Binding var isPresented: Bool

        var body: some View {
            ZStack(alignment: .topTrailing) {
                Color.black.edgesIgnoringSafeArea(.all)

                AsyncImage(url: URL(string: imageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                    }
                }

                // Close Button
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 32))
                        .padding()
                }
            }
        }
    }

    // Fetch the current user's profile
    private func fetchUserProfile() {
        isLoading = true
        if !deal.userID.isEmpty {
            UserService.shared.getUserById(id: deal.userID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedUser):
                        self.user = fetchedUser
                        self.isLoading = false
                    case .failure(let error):
                        self.profileErrorMessage = error.localizedDescription
                        self.isLoading = false
                    }
                }
            }
        }
    }

    // Fetch the current user ID using Firebase Authentication
    private func fetchCurrentUserId() {
        if let currentUser = Auth.auth().currentUser {
            self.currentUserId = currentUser.uid
        } else {
            print("Error: User not authenticated")
            self.voteErrorMessage = "User not authenticated."
        }
    }
    
    // Save deal
    private func saveDeal() {
        
    }
}

#Preview {
    @Previewable @State var deal = Deal(id: "1A3584D9-DF4E-4352-84F1-FA6812AE0A26", userID: "1B7Ra3hPWbOVr2B96mzp3oGXIiK2", photoURL: "", productText: "Prodcut~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", postText: "Product Text~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~", price: 6.8, location: "Safeway", date: "1h", commentIDs: [], upvote: 5, downvote: 6)
    DealInfoView(deal: $deal)
}
