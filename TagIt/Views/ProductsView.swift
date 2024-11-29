//
//  ProductsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-25.
//

// NEED TO BE DISCUSSED... SWIPE or LONG PRESS TO DELETE

import SwiftUI
import FirebaseAuth

struct ProductsView: View {
    @State var userID: String?
    @State var savedDeals: [Deal] = []
    @State var shownDeals: [Deal] = []
    @State var swipedDealID: String?
    @State var selectedDeal: Deal?
    @State var search: String = ""
    @State var isProfileLoading: Bool = true
    @State var isSavedDealsLoading: Bool = true
    @State var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                    
                    TextField("Search", text: $search)
                        .autocapitalization(.none)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(height: 40)
                }
                .padding()
                .onSubmit {
                    print("Searching \"\(search)\"")
                    searchSavedDeals(searchText: search)
                }
                
                // Title
                HStack {
                    Image(systemName: "cart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .foregroundStyle(.green)
                        .padding(.horizontal)
                    
                    Text("Saved Deal List")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Show deals
                if (isProfileLoading || isSavedDealsLoading) {
                    ProgressView("Loading saved deal...")
                        .padding(.top, 20) // Added top padding for spacing
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .padding(.horizontal) // Added horizontal padding for better alignment
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        if shownDeals.isEmpty {
                            ZStack {
                                Spacer().containerRelativeFrame([.horizontal, .vertical])
                                
                                Text("Sorry, there is no saved deals...")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxHeight: .infinity)
                        } else {
                            VStack(alignment: .leading, spacing: 30) {
                                ForEach(shownDeals) { deal in
//                                    SwipeableDealCardView(deal: deal, swipedDealID: $swipedDealID, deleteAction: {
//                                        delSavedDeal(deal: deal)
//                                    })
                                    NavigationLink(destination: DealDetailView(deal: deal)) {
                                        DealCardView1(deal: deal)
                                            .background(Color.white)
                                            .cornerRadius(15)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                            .padding(.horizontal)
                                            .onLongPressGesture {
                                                selectedDeal = deal
                                            }
                                    }
                                }
                            }
                        }
                        
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.top, 10) // Added top padding for spacing
                    .refreshable {
                        // Refresh the saved deal list
                        fetchSavedDeals()
                    }
                    .alert(item: $selectedDeal) { deal in
                        Alert(
                            title: Text("Delete \(deal.productText)?"),
                            message: Text("Are you sure you want to delete this item?"),
                            primaryButton: .destructive(Text("Delete")) {
                                delSavedDeal(deal: deal)
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
            .onAppear() {
                fetchUserProfile()
                // Fetch saved deal list
                fetchSavedDeals()
            }
        }
    }
    
    private func searchSavedDeals(searchText: String) {
        if (searchText == "") {
            shownDeals = savedDeals
        } else {
            shownDeals = savedDeals.filter { $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.productText.localizedCaseInsensitiveContains(searchText) ||
                $0.postText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func fetchUserProfile() {
        self.isProfileLoading = true
        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
            self.isProfileLoading = false
        } else {
            print("Error: User not authenticated")
            self.errorMessage = "User not authenticated."
        }
    }
    
    private func fetchSavedDeals() {
        isSavedDealsLoading = true

        DealService.shared.getSavedDealsByUserID(userID: self.userID!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedDeals):
                    self.savedDeals = savedDeals
                    print("[DEBUG] Fetch saved deals for user \(userID!)")
                    shownDeals = savedDeals
                    self.isSavedDealsLoading = false
                case .failure(let error):
                    print("[DEBUG] Error when fetching saved deals for user \(userID!) due to \(error.localizedDescription)")
                    self.isSavedDealsLoading = false
                }
            }
        }
    }
    
    
    private func delSavedDeal(deal: Deal) {
        withAnimation {
            shownDeals.removeAll { $0.id == deal.id }
        }
        
        DealService.shared.removeSavedDeal(userID: userID!, dealID: deal.id!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("[DEBUG] user \(userID!) successfully deleted saved deal \(deal.id!)")
                case .failure(let error):
                    print("[DEBUG] user \(userID!) fail to delete saved deal \(deal.id!) deu to error \(error.localizedDescription)")
                }
            }
        }
    }
}

struct SwipeableDealCardView: View {
    let deal: Deal
    @Binding var swipedDealID: String?
    let deleteAction: () -> Void

    @State private var offset: CGFloat = 0
    @GestureState private var isDragging: Bool = false

    var body: some View {
        ZStack {
            // Background swipe actions
            HStack {
                Spacer()
                Button(action: deleteAction) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .frame(width: 80, height: 200)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            // Foreground content
            DealCardView(deal: deal)
                .frame(maxWidth: .infinity, minHeight: 200)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 2)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.width < 0 { // Swipe left
                                offset = max(gesture.translation.width, -80) // Limit swipe to 80 points
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.width < -50 { // If swiped enough
                                withAnimation {
                                    swipedDealID = deal.id
                                    offset = -80
                                }
                            } else {
                                withAnimation {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .onChange(of: swipedDealID) { oldValue, newValue in
            if newValue != deal.id {
                withAnimation {
                    offset = 0
                }
            }
        }
    }
}

struct DealCardView1: View {
    let deal: Deal
    @State var isLoading = true
    @State var user: UserProfile?
    @State private var errorMessage: String?
    @State private var commentCount: Int = 0 // Holds the number of comments for the deal
    
    var body: some View {
        //        NavigationLink(destination: DealDetailView(deal: deal)) {
        ZStack {
            Color.white
                .cornerRadius(15) // Rounded corners, no shadow
            
            VStack(alignment: .leading, spacing: 10) {
                // User Info Row with Price
                HStack {
                    if isLoading {
                        ProgressView()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        HStack(spacing: 10) {
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
                    
                    Spacer()
                    
                    // Price
                    Text(String(format: "$%.2f", deal.price))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                }
                
                Divider()
                    .background(Color.gray.opacity(0.5))
                
                // Content Area
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Product Text
                        Text(deal.productText)
                            .font(.headline)
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text("\"\(deal.postText)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .italic()
                            .lineLimit(1)
                        
                        Spacer()
                        
                        HStack(spacing: 5) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.green)
                            Text(deal.location)
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            // Comments Icon and Count
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundColor(.gray) // Updated to gray
                            Text("\(commentCount)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray) // Updated to gray
                        }
                    }
                    
                    Spacer()
                    
                    // Product Image
                    AsyncImage(url: URL(string: deal.photoURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100) // Slightly smaller image
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            ProgressView()
                                .frame(width: 100, height: 100)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding(15) // Add consistent padding inside the card
        }
        .frame(maxWidth: .infinity) // Extend card horizontally
        .padding(.horizontal, 0) // Remove extra padding between cards
        .onAppear {
            fetchUserProfile()
            fetchCommentCount() // Fetch the number of comments for the deal
        }
        //        }
    }
    
    // Function to fetch user profile
    private func fetchUserProfile() {
        isLoading = true
        if deal.userID != "" {
            UserService.shared.getUserById(id: deal.userID) { result in
                switch result {
                case .success(let fetchUserProfilebyID):
                    self.user = fetchUserProfilebyID
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // Function to fetch the number of comments for the deal
    private func fetchCommentCount() {
        guard let dealId = deal.id else { return }
        
        CommentService.shared.getCommentsForItem(itemID: dealId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let comments):
                    self.commentCount = comments.count
                case .failure(let error):
                    print("Error fetching comments for deal \(dealId): \(error.localizedDescription)")
                }
            }
        }
    }
}
#Preview {
    ProductsView()
}
