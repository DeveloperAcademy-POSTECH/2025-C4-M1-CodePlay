//
//  Config.swift
//  성현
//
//  Created by 성현 on 7/25/25.
//

import Foundation

enum Config {
    enum Network {
        static let baseURL = "BASE_URL"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
}

extension Config {
    static let baseURL: String = {
        guard let key = Config.infoDictionary[Network.baseURL] as? String else {
            fatalError("⛔️BASE_URL is not set in plist for this configuration⛔️")
        }
        return key
    }()
}
