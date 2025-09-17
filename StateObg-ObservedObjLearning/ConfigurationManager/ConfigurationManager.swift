//
//  ConfigurationManager.swift
//  StateObg-ObservedObjLearning
//
//  Created by User on 17/09/25.
//

import Foundation

enum ConfigurationManager {
    private static let infoDict: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Could not load info dictionary")
        }
        return dict
    }()
    
    static let ROOT_URL: String = {
        guard let urlString = infoDict["ROOT_URL"] as? String else {
            fatalError("Could not load ROOT_URL")
        }
        return urlString // ✅ FIXED: Return the unwrapped value, not itself
    }()
}
