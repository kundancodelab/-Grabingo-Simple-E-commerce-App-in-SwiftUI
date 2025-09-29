//
//  HomeRouterView.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 29/09/25.
//

import Foundation
import SwiftUI

struct HomeRouterView: View {
    let homeRoute: HomeRoute
    
    @ViewBuilder
    var body: some View {
        switch homeRoute {
        case .home:
            HomeView()
        case .detail(let product):
            ProductDetailView(product: product)
                
        }
    }
}

