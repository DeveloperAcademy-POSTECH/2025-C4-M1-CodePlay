//
//  DefaultMusicPlayerRepository.swift
//  CodePlay
//
//  Created by Assistant on 1/27/25.
//

import Foundation
import MusicKit

// MARK: - Default Music Player Repository Implementation
final class DefaultMusicPlayerRepository: MusicPlayerRepository {
    private let player = ApplicationMusicPlayer.shared
    private var currentTrackId: String?
    private var isCurrentlyPlaying: Bool = false
    
    func playTrack(trackId: String) async throws {
        // Apple Music 권한 확인
        let authorizationStatus = await MusicAuthorization.request()
        guard authorizationStatus == .authorized else {
            throw MusicPlayerError.authorizationRequired
        }
        
        // MusicKit으로 곡 정보 가져오기
        let musicItemID = MusicItemID(trackId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        
        guard let song = response.items.first else {
            throw MusicPlayerError.trackNotFound(trackId)
        }
        
        // 재생 시작
        player.queue = [song]
        try await player.play()
        
        currentTrackId = trackId
        isCurrentlyPlaying = true
    }
    
    func pauseTrack() async throws {
        try await player.pause()
        isCurrentlyPlaying = false
    }
    
    func stopTrack() async throws {
        try await player.stop()
        currentTrackId = nil
        isCurrentlyPlaying = false
    }
    
    func getCurrentPlayingStatus() -> (trackId: String?, isPlaying: Bool) {
        return (currentTrackId, isCurrentlyPlaying)
    }
}

// MARK: - Music Player Errors
enum MusicPlayerError: LocalizedError {
    case authorizationRequired
    case trackNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationRequired:
            return "Apple Music 권한이 필요합니다"
        case .trackNotFound(let trackId):
            return "곡을 찾을 수 없습니다: \(trackId)"
        }
    }
} 