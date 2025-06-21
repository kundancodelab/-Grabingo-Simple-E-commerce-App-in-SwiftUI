//
//  DashboardVM.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 10/06/25.
//

import Foundation
import SwiftUI

class DashboardVM: ObservableObject {
    @Published var title: String = "Fashion Products"
    @Published var productData: [ProductDM] = []
    @Published var cartItems: [ProductDM] = []
    @Published var wishlistItems: [ProductDM] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var toastMessage: String?
    @Published var isError: Bool = false
    init(){
        fetchProductData { [weak self] data, error in
            guard let _ = self else { return }
            if let _ = error {
              print("Fetching data failed")
              
            }else {
                print("Data fetched successfully")
            }
          
        }
    }
    
    
    // MARK: Old method using completion handler fetcing product.
    func fetchProductData(completion: @escaping ([ProductDM]?, Error?) -> Void) {
           guard let url = URL(string: ConstantAPI.shared.baseURL) else {
               print(" Invalid URL")
               DispatchQueue.main.async {
                   self.isError = true
                   self.errorMessage = "Invalid URL"
               }
               completion(nil, NSError(domain: "", code: 0, userInfo: nil))
               return
           }

           URLSession.shared.dataTask(with: url) { data, response, error in
               if let error = error {
                   DispatchQueue.main.async {
                       self.isError = true
                       self.errorMessage = "\(error.localizedDescription)"
                   }
                   print(" Error fetching data:", error.localizedDescription)
                   completion(nil, error)
                   return
               }
               
               if let httpResponse = response as? HTTPURLResponse {
                   if httpResponse.statusCode != 200 {
                       DispatchQueue.main.async {
                           self.isError = true
                           self.errorMessage = "Server returned status code \(httpResponse.statusCode)"
                       }
                       completion(nil, NSError(domain: "", code: httpResponse.statusCode, userInfo: nil))
                       return
                   }
               }

               guard let data = data else {
                   print(" No data received")
                   DispatchQueue.main.async {
                       self.isError = true
                       self.errorMessage = "\(error?.localizedDescription)"
                   }
                   completion(nil, NSError(domain: "", code: 0, userInfo: nil))
                   return
               }

               do {
                   let products = try JSONDecoder().decode([ProductDM].self, from: data)
                   DispatchQueue.main.async {
                       self.productData = products
                       completion(self.productData,nil)
                   }
               } catch {
                   DispatchQueue.main.async {
                       self.isError = true
                       self.errorMessage = "\(error.localizedDescription)"
                   }
                   print(" JSON decoding failed:", error)
                   completion(nil, error)
               }
           }.resume()
       }
    
    
    
    // MARK:  New method using async/await fetching a product.
    @MainActor
       func fetchProductDataAsync() async {
           guard let url = URL(string: ConstantAPI.shared.baseURL) else {
               isError = true
               errorMessage = "Invalid URL"
               print("Invalid URL")
               return
           }

           do {
               let (data, response) = try await URLSession.shared.data(from: url)
               
               if let httpResponse = response as? HTTPURLResponse {
                   print("Status Code: \(httpResponse.statusCode)")
                   if !(200...299).contains(httpResponse.statusCode) {
                       isError = true
                       errorMessage = "Server error (status code: \(httpResponse.statusCode))"
                       return
                   }
               }
               
               let products = try JSONDecoder().decode([ProductDM].self, from: data)
               self.productData = products
               print("Data fetched successfully (async)")
           } catch {
               isError = true
               errorMessage = "\(error.localizedDescription)"
               print("Async fetch failed:", error)
           }
       }
    
    // MARK: - Add to Cart
       func addToCart(_ product: ProductDM) {
           if !cartItems.contains(where: { $0.id == product.id }) {
               cartItems.append(product)
               showToast(message: "Added to cart 🛒")
           } else {
               showToast(message: "Already in cart!")
           }
       }
    
    // MARK: - Add to Wishlist
      func addToWishlist(_ product: ProductDM) {
          if !wishlistItems.contains(where: { $0.id == product.id }) {
              wishlistItems.append(product)
              showToast(message: "Saved to wishlist ❤️")
          } else {
              showToast(message: "Already in wishlist!")
          }
      }
    // MARK: - Buy Now
       func buyNow(_ product: ProductDM) {
           showToast(message: "Processing order for '\(product.title)' 💸")
           // Simulate delay
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               self.showToast(message: "Purchase Successful ✅")
           }
       }
    
    // MARK: - Show Toast
        private func showToast(message: String) {
            toastMessage = message
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.toastMessage = nil
            }
        }

}
