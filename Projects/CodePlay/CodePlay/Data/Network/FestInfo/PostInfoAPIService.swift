//
//  NotificationAPIService.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/18/25.
//

import Foundation
import Moya

// MARK: NotificationAPIService
protocol PostInfoAPIServiceProtocol {
    func postFestInfoText(model: PostFestInfoTextRequestDTO) async throws -> PostFestInfoResponseDTO
    func postFestInfoVision(model: PostFestInfoVisionRequestDTO) async throws -> PostFestInfoResponseDTO
}

// MARK: DefaultNotificationAPIService
final class PostInfoAPIService: BaseAPIService<PostInfoTargetType>, PostInfoAPIServiceProtocol {
    
    private let provider = MoyaProvider<PostInfoTargetType>(plugins: [MoyaLoggerPlugin()])
    
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
    
    func postFestInfoVision(model: PostFestInfoVisionRequestDTO) async throws -> PostFestInfoResponseDTO {
        let response = try await provider.request(.postFestInfoVision(model: model))
        
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

