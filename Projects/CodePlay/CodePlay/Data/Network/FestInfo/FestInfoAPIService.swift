//
//  NotificationAPIService.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/18/25.
//

import Foundation
import Moya

// MARK: NotificationAPIService
protocol FestInfoAPIServiceProtocol {
    func postDeviceToken(model: PostDeviceTokenRequestDTO) async throws -> [PostDeviceTokenResponseDTO]
}

// MARK: DefaultNotificationAPIService
final class FestInfoAPIService: BaseAPIService<NotificationTargetType>, FestInfoAPIServiceProtocol {
    
    private let provider = MoyaProvider<NotificationTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func postDeviceToken(model: PostDeviceTokenRequestDTO) async throws -> [PostDeviceTokenResponseDTO] {
        let response = try await provider.request(.postDeviceToken(model: model))
        
        let result: NetworkResult<PostDeviceTokenResponseDTO> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data
        )
        
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return [data]
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}

