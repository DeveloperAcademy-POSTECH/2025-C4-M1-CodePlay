//
//  MusicKitTokenAPIService.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation
import Moya

protocol MusicKitTokenAPIServiceProtocol {
    func fetchDeveloperToken() async throws -> MusicKitTokenResponseDTO
}

final class MusicKitTokenAPIService:
    BaseAPIService<MusicKitTokenTargetType>, MusicKitTokenAPIServiceProtocol {

    private let provider: MoyaProvider<MusicKitTokenTargetType>

    init(baseURL: URL, plugins: [PluginType] = [MoyaLoggerPlugin()]) {
        MusicKitTokenTargetType.injectedBaseURL = baseURL
        self.provider = MoyaProvider<MusicKitTokenTargetType>(plugins: plugins)
    }

    func fetchDeveloperToken() async throws -> MusicKitTokenResponseDTO {
        let response = try await provider.request(.devToken)

        let result: NetworkResult<MusicKitTokenResponseDTO> =
            fetchNetworkResult(statusCode: response.statusCode, data: response.data)

        switch result {
        case .success(let dto):
            guard let dto else { throw NetworkResult<Error>.decodeErr }
            return dto
        default:
            throw NetworkResult<Error>.networkFail
        }
    }
}
