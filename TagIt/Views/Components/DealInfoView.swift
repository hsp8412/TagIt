import FirebaseAuth
import SwiftUI

/**
 A view that displays detailed information about a deal, including the product image, user details, product details, and location.
 It also allows users to upvote, downvote, and save deals, with a photo expansion feature for the deal's image.
 */
struct DealInfoView: View {
    // MARK: - Properties

    /// The deal to display in the view.
    @Binding var deal: Deal
    /// State variables for loading and error handling.
    @State var isProfileLoading = true
    @State var isVoteLoading = true
    @State var isSaved = false
    @State private var jump = false // State for jump animation on save button
    @State var curUserProfile: UserProfile?
    @State var user: UserProfile?
    @State private var profileErrorMessage: String?
    @State private var voteErrorMessage: String?
    @State private var currentUserId: String? = nil
    @State private var isPhotoExpanded: Bool = false // State to toggle photo expansion

    // MARK: - View Body

    var body: some View {
        VStack(spacing: 15) {
            // Product Image Section
            ZStack {
                AsyncImage(url: URL(string: deal.photoURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle()) // Restrict gesture area to the image
                            .onTapGesture {
                                isPhotoExpanded = true // Expand the photo on tap
                                UIApplication.shared.hideKeyboard()
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
                .onTapGesture {
                    UIApplication.shared.hideKeyboard()
                }
            }.background(Color.white // <-- this is also a view
                .onTapGesture { // <-- add tap gesture to it
                    UIApplication.shared.hideKeyboard()
                })
                .padding(.bottom, 10)

            Divider()
                .background(Color.gray.opacity(0.5))

            // User Info Section
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        if isProfileLoading {
                            ProgressView()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle()) // Show a loading indicator while fetching user profile
                        } else if let profileErrorMessage {
                            Text("Error: \(profileErrorMessage)")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else {
                            UserAvatarView(avatarURL: user?.avatarURL ?? "")
                                .frame(width: 40, height: 40)
                                .clipShape(Circle()) // User avatar

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user?.displayName ?? "Unknown User")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)

                                Text(deal.date)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray) // Display the deal's date
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
                        }
                    }
                }
                .padding(10)

                HStack {
                    Spacer()
                    Button(action: {
                        // Step 1: Animate the fill color change
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isSaved.toggle() // Toggle the state to change the color
                        }

                        // Step 2: Animate the pop-out effect after the color change
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            // Pop out - Move up and scale up
                            withAnimation(.easeOut(duration: 0.15)) {
                                jump = true
                            }

                            // Step 3: Move back down and scale back to original size
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    jump = false
                                }
                            }
                        }

                        saveDeal()
                    }) {
                        Image(systemName: isSaved ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSaved ? .green : .gray) // Color changes with state
                            .scaleEffect(jump ? 2.0 : 1.0) // Scale up when jumping
                            .offset(y: jump ? -20 : 0) // Move up when jumping
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.trailing)
            }
            .padding(15)
            .background(
                Color.white
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
        }
        .onAppear {
            fetchCurrentUserProfile()
            fetchUserProfile()
        }
        .fullScreenCover(isPresented: $isPhotoExpanded) {
            PhotoFullScreenView(imageURL: deal.photoURL, isPresented: $isPhotoExpanded)
        }
    }

    /**
     A full-screen view to display an image when tapped.
     */
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

    // MARK: - Helper Functions

    /**
     Fetches the user profile associated with the deal.
     This function is called to display the user information when the deal card appears.
     */
    private func fetchUserProfile() {
        isProfileLoading = true
        if !deal.userID.isEmpty {
            UserService.shared.getUserById(id: deal.userID) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(fetchedUser):
                        user = fetchedUser
                        isProfileLoading = false
                    case let .failure(error):
                        profileErrorMessage = error.localizedDescription
                        isProfileLoading = false
                    }
                }
            }
        }
    }

    /**
     Fetches the current user ID using Firebase Authentication.
     */
    private func fetchCurrentUserProfile() {
        isVoteLoading = true

        if let currentUser = Auth.auth().currentUser {
            currentUserId = currentUser.uid

            UserService.shared.getUserById(id: currentUserId!) { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(fetchedUser):
                        curUserProfile = fetchedUser

                        if curUserProfile?.savedDeals.firstIndex(of: deal.id!) != nil {
                            isSaved = true
                        } else {
                            isSaved = false
                        }

                        isVoteLoading = false
                    case let .failure(error):
                        voteErrorMessage = error.localizedDescription
                        isVoteLoading = false
                    }
                }
            }
        } else {
            print("Error: User not authenticated")
            voteErrorMessage = "User not authenticated."
        }
    }

    /**
     Saves or removes the deal from the user's saved deals list.
     */
    private func saveDeal() {
        if isSaved {
            DealService.shared.addSavedDeal(userID: currentUserId!, dealID: deal.id!) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("[DEBUG] user \(currentUserId!) successfully saved deal \(deal.id!)")
                    case let .failure(error):
                        print("[DEBUG] user \(currentUserId!) failed to save deal \(deal.id!) due to error \(error.localizedDescription)")
                    }
                }
            }
        } else {
            DealService.shared.removeSavedDeal(userID: currentUserId!, dealID: deal.id!) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("[DEBUG] user \(currentUserId!) successfully deleted saved deal \(deal.id!)")
                    case let .failure(error):
                        print("[DEBUG] user \(currentUserId!) failed to delete saved deal \(deal.id!) due to error \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
