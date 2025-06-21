//
//  ProductViewCell.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 10/06/25.
//
import SwiftUI
import Kingfisher

struct ProductViewCell: View {
    let product: ProductDM

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 16) {
                KFImage(URL(string: product.image)) // ✅ Use Kingfisher to load image from URL
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    Text("₹\(product.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }

                Spacer()
            }
            .padding()
        }
    }
}
#Preview {
    ProductViewCell(product: ProductDM(
        id: 1,
        title: "Sample Product",
        price: 99.99,
        description: "This is a test product used for preview.",
        category: "Electronics",
        image: "https://via.placeholder.com/100",
        rating: Rating(rate: 4.5, count: 120)
    ))
}
