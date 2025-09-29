//
//  HomeView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 22/06/25.
//

import SwiftUI


struct HomeView: View {
    @EnvironmentObject var router :Router
    @StateObject var dashboardVM = DashboardVM()
    
    var body: some View {
        VStack {
            HStack {
                Text("\(dashboardVM.title)")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            List(dashboardVM.productData) { product in
                NavigationLink(destination: ProductDetailView(product: product)
                    .environmentObject(dashboardVM)
                ) {
                    ProductViewCell(product: product)
                }
                
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }.listStyle(PlainListStyle())
                .refreshable {
                    await dashboardVM.fetchProductDataAsync()
                    
                }
        }.padding()
        
            .alert("Error", isPresented: $dashboardVM.isError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(dashboardVM.errorMessage ?? "Something went wrong.")
            }
        
        
        
    }
}

#Preview {
    ProductView()
        .environmentObject(DashboardVM())
}
