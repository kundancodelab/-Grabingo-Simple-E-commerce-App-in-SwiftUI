//
//  ProductDM.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 10/06/25.
//

import Foundation

// MARK: - Product Model
struct ProductDM: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}

// MARK: - Rating Model
struct Rating: Codable {
    let rate: Double
    let count: Int
}
