//
//  AppconfigAPIService.swift
//  CodePlay
//
//  Created by 성현 on 9/25/25.
//

import Foundation
import Moya

protocol AppConfigAPIServiceProtocol {
    func getAppConfig(platform: String) async throws -> GetAppConfigResponseDTO
}

final class AppConfigAPIService: BaseAPIService<AppConfigTargetType>, AppConfigAPIServiceProtocol {
    private let provider = MoyaProvider<AppConfigTargetType>(plugins: [MoyaLoggerPlugin()])

    func getAppConfig(platform: String = "ios") async throws -> GetAppConfigResponseDTO {
        let response = try await provider.request(.getAppConfig(platform: platform))
        let result: NetworkResult<GetAppConfigResponseDTO> = fetchNetworkResult(
            statusCode: response.statusCode,
            data: response.data
        )

        switch result {
        case .success(let data):
            guard let data else { throw NetworkResult<Error>.decodeErr }
            return data
        case .badRequest:     throw NetworkResult<Error>.badRequest
        case .unAuthorized:   throw NetworkResult<Error>.unAuthorized
        case .notFound:       throw NetworkResult<Error>.notFound
        case .unProcessable:  throw NetworkResult<Error>.unProcessable
        default:              throw NetworkResult<Error>.networkFail
        }
    }
}
