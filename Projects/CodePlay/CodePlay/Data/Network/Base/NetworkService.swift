//
//  NetworkService.swift
//  CodePlay
//
//  Created by 성현 on 7/24/25.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()

    private init() {}
    
    let notificationService: NotificationAPIServiceProtocol = NotificationAPIService()
    let festivalinfoService: FestInfoAPIServiceProtocol = FestInfoAPIService()
}
