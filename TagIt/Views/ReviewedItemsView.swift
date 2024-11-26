//
//  ReviewedItemsView.swift
//  TagIt
//
//  Created by Chenghou Si on 2024-11-26.
//

import SwiftUI
import FirebaseAuth

struct ReviewedItemsView: View {
    @State var reviews: [BarcodeItemReview] = []
    @State var shownReviews: [BarcodeItemReview] = []
    @State var userID: String?
    @State var search: String = ""
    @State var isLoading: Bool = true
    @State var errorMessage: String?

    var body: some View {
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
                searchReviews(searchText: search)
            }
            
            // Title
            HStack {
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                    .foregroundStyle(.green)
                    .padding(.horizontal)
                
                Text("Reviewed Items")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Reviews
            if isLoading {
                ProgressView("Loading deals...")
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    if shownReviews.isEmpty {
                        ZStack {
                            Spacer().containerRelativeFrame([.horizontal, .vertical])
                            
                            Text("Sorry, you have not reviewed any items...")
                                .foregroundColor(.gray)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(shownReviews) { review in
                                ReviewCardView1(review: review)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                }
                .padding(.top, 10)
                .refreshable {
                    fetchReviews()
                }
            }
        }
        .onAppear() {
            fetchReviews()
        }
    }
    
    private func fetchReviews() {
        if (self.userID == nil) {
            if let currentUser = Auth.auth().currentUser {
                self.userID = currentUser.uid
            } else {
                print("Error: User not authenticated")
                self.errorMessage = "User not authenticated."
                return
            }
        }
        
        ReviewService.shared.getAllUserReviews(userID: userID!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let reviews):
                    self.reviews = reviews
                    print("[DEBUG] Fetch reviews for user \(userID!)")
                    shownReviews = reviews
                    self.isLoading = false
                case .failure(let error):
                    print("[DEBUG] Error when fetching all reviews for user \(userID!) due to \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    private func searchReviews(searchText: String) {
        if (searchText == "") {
            shownReviews = reviews
        } else {
            shownReviews = reviews.filter { $0.productName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    ReviewedItemsView()
}
