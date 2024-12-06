//
//  NewDealView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

/**
 A view that allows users to add a new deal. It includes fields for the product name, price, location, and details,
 as well as options to upload an image. Once the form is completed, the user can submit the deal.
 */
struct NewDealView: View {
    // MARK: - Properties

    /// The view model responsible for managing the new deal form data.
    @StateObject var viewModel: NewDealViewModel

    // MARK: - Initializer

    init(selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: NewDealViewModel(selectedTab: selectedTab)) // Pass the selectedTab binding to the ViewModel
    }

    // MARK: - View Body

    var body: some View {
        if viewModel.isLoading {
            ProgressView() // Show loading indicator while data is being fetched
        } else {
            NavigationStack {
                ScrollView {
                    VStack {
                        ZStack {
                            Color(UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)) // Background color
                                .onTapGesture {
                                    UIApplication.shared.hideKeyboard() // Dismiss keyboard when tapping outside
                                }
                            VStack {
                                // Title with gradient
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.green)
                                    Text("Add a new deal")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black)
                                        .font(.system(size: 40))
                                        .overlay(
                                            LinearGradient(gradient: Gradient(colors: [.green, .purple]), startPoint: .leading, endPoint: .trailing)
                                                .mask(
                                                    Text("Add a new deal")
                                                        .fontWeight(.bold)
                                                        .font(.system(size: 40))
                                                )
                                        )
                                }
                                .padding(.vertical, 20)

                                // Image Upload Section
                                ImageUploadView(
                                    imageToUpload: $viewModel.image, // Bind image to the reusable component
                                    placeholderImage: UIImage(named: "addImageIcon")!,
                                    width: 120,
                                    height: 120
                                ).padding(.trailing, 20)

                                // Form for input fields
                                VStack(spacing: 20) {
                                    VStack(alignment: .leading) {
                                        Text("Product Name")
                                            .foregroundStyle(.black)
                                            .opacity(0.7)
                                        TextField("Product Name", text: $viewModel.productText)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .autocapitalization(.none)
                                    }

                                    VStack(alignment: .leading) {
                                        Text("Price")
                                            .foregroundStyle(.black)
                                            .opacity(0.7)
                                        TextField("Price", text: $viewModel.price)
                                            .keyboardType(.decimalPad) // Use the decimal pad keyboard
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .autocapitalization(.none)
                                    }

                                    VStack(alignment: .leading) {
                                        Text("Location")
                                            .foregroundStyle(.black)
                                            .opacity(0.7)

                                        Picker("Location", selection: $viewModel.location) {
                                            Text("Select a Location").tag(nil as Store?)
                                            ForEach(viewModel.stores) { store in
                                                Text(store.name).tag(store as Store?)
                                            }
                                        }
                                        .pickerStyle(.navigationLink)
                                        .onChange(of: viewModel.location) { _, _ in
                                            viewModel.locationTouched = true
                                        }

                                        .onAppear {
                                            if viewModel.locationTouched == false {
                                                viewModel.getClosestStore() // Automatically set the closest store on appear
                                            }
                                        }
                                    }

                                    VStack(alignment: .leading) {
                                        Text("Details")
                                            .foregroundStyle(.black)
                                            .opacity(0.7)
                                        TextEditor(text: $viewModel.postText)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                            .autocapitalization(.none)
                                            .frame(height: 150)
                                    }
                                }
                                .padding(.horizontal, 40)

                                // Error message if there's an issue
                                if let errorMessage = viewModel.errorMessage {
                                    Text(errorMessage)
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                // Submit Button
                                Button(action: {
                                    viewModel.handleSubmit() // Submit the new deal
                                }) {
                                    if viewModel.submitted {
                                        ProgressView() // Show loading indicator while submitting
                                    } else {
                                        Text("Submit")
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 15)
                                            .background(.green)
                                            .foregroundColor(.white)
                                            .cornerRadius(25)
                                    }
                                }.padding(.vertical, 20)

                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StatePreviewWrapper() // Wrapper to simulate preview state
}

struct StatePreviewWrapper: View {
    @State private var selectedTab = 0

    var body: some View {
        NewDealView(selectedTab: $selectedTab) // Pass the mock binding
    }
}
