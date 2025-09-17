//
//  String+Extension.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 17/09/25.
//

import Foundation

extension String {
    func initials() -> String {
        components(separatedBy: " ")
            .prefix(2)
            .compactMap { $0.first?.uppercased() }
            .joined()
    }
}
