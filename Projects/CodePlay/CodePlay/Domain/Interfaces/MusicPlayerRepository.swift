import Foundation
import MusicKit

// MARK: - Music Player Repository Interface
protocol MusicPlayerRepository {
    /// 특정 트랙 재생
    func playTrack(trackId: String) async throws
    
    /// 재생 일시정지
    func pauseTrack() async
    
    /// 재생 정지
    func stopTrack() async

    /// 현재 재생 상태 조회
    func getCurrentPlayingStatus() -> (trackId: String?, isPlaying: Bool)
    
    /// 음악 캐싱 관련 메서드들
    func cacheSong(_ song: Song, for trackId: String)
    func preloadSongToMemory(_ song: Song, for trackId: String) async
}

// MARK: - Default Music Player Repository Implementation
final class DefaultMusicPlayerRepository: MusicPlayerRepository {
    private let player = ApplicationMusicPlayer.shared
    private var currentTrackId: String?
    private var isCurrentlyPlaying: Bool = false
    
    func playTrack(trackId: String) async throws {
        let authorizationStatus = await MusicAuthorization.request()
        guard authorizationStatus == .authorized else {
            throw MusicPlayerError.authorizationRequired
        }
        
        let musicItemID = MusicItemID(trackId)
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        
        guard let song = response.items.first else {
            throw MusicPlayerError.trackNotFound(trackId)
        }
        
        player.queue = [song]
        try await player.play()
        
        currentTrackId = trackId
        isCurrentlyPlaying = true
    }
    
    func pauseTrack() async {
        player.pause()
        isCurrentlyPlaying = false
    }
    
    func stopTrack() async {
        player.stop()
        currentTrackId = nil
        isCurrentlyPlaying = false
    }

    func getCurrentPlayingStatus() -> (trackId: String?, isPlaying: Bool) {
        return (currentTrackId, isCurrentlyPlaying)
    }
    
    // MARK: - 음악 캐싱 관련 메서드들
    func cacheSong(_ song: Song, for trackId: String) {
    }
    
    func preloadSongToMemory(_ song: Song, for trackId: String) async {
        if let previewURL = song.previewAssets?.first?.url {
        } else {
        }
    }
}
