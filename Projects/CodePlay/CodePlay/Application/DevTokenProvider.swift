//
//  DevTokenProvider.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation

actor DevTokenProvider {
    private let api: MusicKitTokenAPIServiceProtocol
    private var cachedToken: String?
    private var expiry: Date = .distantPast

    init(api: MusicKitTokenAPIServiceProtocol) { self.api = api }

    func getValidToken() async throws -> String {
        let now = Date()
        if let t = cachedToken, now < expiry.addingTimeInterval(-300) {
            return t
        }
        let dto = try await api.fetchDeveloperToken()
        cachedToken = dto.token
        expiry = dto.expiryDate
        return dto.token
    }
}
