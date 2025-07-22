

import Foundation

// MARK: - Music Player Repository Interface
protocol MusicPlayerRepository {
    /// 특정 트랙 재생
    func playTrack(trackId: String) async throws
    
    /// 현재 재생 중인 트랙 일시정지
    func pauseTrack() async throws
    
    /// 현재 재생 중인 트랙 정지
    func stopTrack() async throws
    
    /// 현재 재생 상태 조회
    func getCurrentPlayingStatus() -> (trackId: String?, isPlaying: Bool)
} 
