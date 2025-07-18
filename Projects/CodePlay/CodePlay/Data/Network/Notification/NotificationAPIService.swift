//
//  NotificationAPIService.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/18/25.
//

import Foundation

// MARK: NotificationAPIService
protocol NotificationAPIService {
    /// 디바이스 토큰 요청용 함수
    func postDeviceToken(model: DeviceTokenRequestDTO) async throws -> DeviceTokenResponseDTO
}

// MARK: DefaultNotificationAPIService
final class DefaultNotificationAPIService: NotificationAPIService {
    private let session: URLSession
    // TODO: API 사용하게 되면 baseURL, 라우터 분리 예정
    private let baseURL = URL(string: "https://api.example.com/notification")
    
    init(session: URLSession) {
        self.session = session
    }
    
    func postDeviceToken(model: DeviceTokenRequestDTO) async throws -> DeviceTokenResponseDTO {
        var request = URLRequest(url: baseURL!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(model)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoded = try JSONDecoder().decode(DeviceTokenResponseDTO.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
