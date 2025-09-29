//
//  ProductDetailView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 10/06/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: ProductDM?
    @EnvironmentObject var dashboardVM: DashboardVM
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                AsyncImage(url: URL(string: product?.image ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 250)

                Text(product?.title ?? "NA")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(product?.description ?? "NA" )
                    .font(.body)

                Text("Category: \(product?.category)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Price: ₹\(product?.price ?? 0.0 , specifier: "%.2f")")
                    .font(.title3)
                    .foregroundColor(.green)

                Text("Rating: \(product?.rating.rate ?? 0.0) ⭐️ (\(product?.rating.count) reviews)")
                    .font(.subheadline)
                    .foregroundColor(.orange)

                HStack(spacing: 12) {
                    Button("🛒 Add to Cart") {
                        guard let product = product else {return}
                        dashboardVM.addToCart(product)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("❤️ Wishlist") {
                        guard let product = product else {return}
                        dashboardVM.addToWishlist(product)
                    }
                    .buttonStyle(.bordered)
                }

                Button("💸 Buy Now") {
                    guard let product = product else {return}
                    dashboardVM.buyNow(product)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

            }
            .padding()
        }
        .navigationTitle(product?.title ?? "NA")
        .overlay(
            Group {
                if let message = dashboardVM.toastMessage {
                    Text(message)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .transition(.opacity)
                        .padding()
                }
            },
            alignment: .top
        )
    }
}
