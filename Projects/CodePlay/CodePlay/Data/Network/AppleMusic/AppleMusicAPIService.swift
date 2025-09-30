//
//  AppleMusicAPIService.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation
import Moya
internal import Alamofire

protocol AppleMusicAPIServiceProtocol {
    func searchArtists(term: String, limit: Int, storefront: String) async throws -> GetArtistsResponseDTO
    func topSongs(artistId: String, limit: Int, storefront: String) async throws -> GetTopSongsResponseDTO
}

final class AppleMusicAPIService:
    BaseAPIService<AppleMusicTargetType>, AppleMusicAPIServiceProtocol {

    private lazy var provider: MoyaProvider<AppleMusicTargetType> = {
        var list = extraPlugins
        // 최신 토큰을 매 요청 헤더에 (self 캡처는 lazy 시점에 안전)
        list.insert(AppleMusicAuthPlugin(tokenAccessor: { [weak self] in self?.currentToken }), at: 0)
        list.append(MoyaLoggerPlugin())
        return MoyaProvider<AppleMusicTargetType>(plugins: list)
    }()
    private let tokenProvider: DevTokenProvider
    private let extraPlugins: [PluginType]
    // 플러그인이 읽을 현재 토큰
    private var currentToken: String?

    init(tokenProvider: DevTokenProvider, plugins: [PluginType] = []) {
        self.tokenProvider = tokenProvider
        self.extraPlugins = plugins
        super.init()
    }

    private func ensureToken() async throws {
        // 요청 전에 토큰 갱신/세팅
        self.currentToken = try await tokenProvider.getValidToken()
    }

    func searchArtists(term: String, limit: Int, storefront: String) async throws -> GetArtistsResponseDTO {
        try await ensureToken()
        let resp = try await provider.requestWithBackoff(.search(term: term, types: ["artists"], limit: limit, storefront: storefront))
        let result: NetworkResult<GetArtistsResponseDTO> = fetchNetworkResult(statusCode: resp.statusCode, data: resp.data)
        switch result {
        case .success(let dto): return dto!
        default: throw NetworkResult<Error>.decodeErr
        }
    }

    func topSongs(artistId: String, limit: Int, storefront: String) async throws -> GetTopSongsResponseDTO {
        try await ensureToken()
        let resp = try await provider.request(.artistTopSongs(artistId: artistId, limit: limit, storefront: storefront))
        let result: NetworkResult<GetTopSongsResponseDTO> = fetchNetworkResult(statusCode: resp.statusCode, data: resp.data)
        switch result {
        case .success(let dto): return dto!
        default: throw NetworkResult<Error>.decodeErr
        }
    }
}
