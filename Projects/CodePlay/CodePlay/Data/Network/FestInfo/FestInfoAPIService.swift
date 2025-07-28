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
    func postFestInfoText(model: PostFestInfoTextRequestDTO) async throws -> PostFestInfoResponseDTO
}

// MARK: DefaultNotificationAPIService
final class FestInfoAPIService: BaseAPIService<FestInfoTargetType>, FestInfoAPIServiceProtocol {
    
    private let provider = MoyaProvider<FestInfoTargetType>(plugins: [MoyaLoggerPlugin()])
    
    func postFestInfoText(model: PostFestInfoTextRequestDTO) async throws -> PostFestInfoResponseDTO {
        let response = try await provider.request(.postFestInfoText(model: model))
        
        let result: NetworkResult<PostFestInfoResponseDTO> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data
        )
        
        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}
