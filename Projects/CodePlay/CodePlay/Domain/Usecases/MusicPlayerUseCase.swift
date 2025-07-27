

import Foundation

import MusicKit

// MARK: - Music Player Use Case Protocol
protocol MusicPlayerUseCase {
    /// 30초 미리듣기 재생 시작 (비즈니스 로직)
    func playPreview(trackId: String) async
    
    /// 미리듣기 정지
    func stopPreview() async
    
    /// 현재 재생 상태 조회
    var currentPlayingTrackId: String? { get }
    var isPlaying: Bool { get }
    
    /// Repository 접근을 위한 프로퍼티
    var musicRepository: MusicPlayerRepository { get }
    
    /// Repository 콜백 설정 메서드
    func setupRepositoryCallbacks(
        onPlaybackStateChanged: @escaping (String?, Bool) -> Void,
        onProgressChanged: @escaping (Double) -> Void
    )
    
    // MARK: - Enhanced Preview Methods
    /// 즉시 미리듣기 재생 (캐시 우선, fallback 지원)
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 캐시에서 즉시 재생되었는지 여부
    func playPreviewInstantly(trackId: String) async -> Bool
    
    /// Song 객체를 캐시에 저장
    /// - Parameters:
    ///   - song: 캐싱할 Song 객체
    ///   - trackId: 트랙 ID
    func cacheSong(_ song: Song, for trackId: String)
    
    // MARK: - Memory Caching Methods
    /// Song을 메모리에 프리로드 (최고 성능)
    /// - Parameters:
    ///   - song: MusicKit Song 객체
    ///   - trackId: 트랙 ID
    func preloadSongToMemory(_ song: Song, for trackId: String) async
    
    /// 메모리 캐시 상태 확인
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 메모리에 캐싱되어 있는지 여부
    func isTrackCachedInMemory(trackId: String) -> Bool
}


// MARK: - Default Music Player Use Case Implementation
final class DefaultMusicPlayerUseCase: MusicPlayerUseCase {
    private var repository: MusicPlayerRepository
    var onPlaybackStateChanged: ((String?, Bool) -> Void)?
    var onProgressChanged: ((Double) -> Void)?
    
    // Repository 접근을 위한 프로퍼티
    var musicRepository: MusicPlayerRepository {
        return repository
    }
    
    // Repository 콜백 설정 메서드 구현
    func setupRepositoryCallbacks(
        onPlaybackStateChanged: @escaping (String?, Bool) -> Void,
        onProgressChanged: @escaping (Double) -> Void
    ) {
        repository.onPlaybackStateChanged = onPlaybackStateChanged
        repository.onProgressChanged = onProgressChanged
    }
    
    var playbackProgress: Double {
        return repository.playbackProgress
    }
    
    var currentPlayingTrackId: String? {
        repository.getCurrentPlayingStatus().trackId
    }
    
    var isPlaying: Bool {
        repository.getCurrentPlayingStatus().isPlaying
    }
    
    init(repository: MusicPlayerRepository) {
        self.repository = repository
    }
    
    func playPreview(trackId: String) async {
        await repository.playPreview(trackId: trackId)
    }
    
    func pausePreview() async {
        await repository.pausePreview()
    }
    
    func stopPreview() async {
        await repository.stopPreview()
    }
    
    func togglePreview(for trackId: String) async {
        await repository.togglePreview(for: trackId)
    }
    
    // MARK: - Enhanced Preview Implementation
    func playPreviewInstantly(trackId: String) async -> Bool {
        let currentStatus = repository.getCurrentPlayingStatus()
        
        // 동일한 곡이 재생 중이면 일시정지/재개 토글
        if currentStatus.trackId == trackId {
            if currentStatus.isPlaying {
                await repository.pausePreview()
                print("⏸️ 일시정지: \(trackId)")
            } else {
                // 이미 로드된 곡이므로 즉시 재개 가능
                do {
                    try await repository.resumeCurrentTrack()
                    print("▶️ 재개: \(trackId)")
                } catch {
                    print("❌ 재개 실패: \(error)")
                    // 재개 실패 시 새로 재생 시도
                    await repository.playPreview(trackId: trackId)
                }
            }
            return true
        }
        
        // 다른 곡: 메모리 캐시 1차 우선 재생 (최고 성능)
        let memoryPlaySuccess = await repository.playFromMemoryCache(trackId: trackId)
        if memoryPlaySuccess {
            print("⚡ 메모리에서 즉시 재생: \(trackId)")
            return true
        }
        
        // 2차: 기존 Song 캐시에서 재생
        if let cachedSong = repository.getCachedSong(for: trackId) {
            await repository.playPreviewFromCache(song: cachedSong)
            print("🚀 Song 캐시에서 재생: \(trackId)")
            return true
        }
        
        // 3차: 네트워크에서 새로 재생 (fallback)
        await repository.playPreview(trackId: trackId)
        print("⏳ 네트워크에서 재생: \(trackId)")
        return false
    }
    
    func cacheSong(_ song: Song, for trackId: String) {
        repository.storeCachedSong(song, for: trackId)
    }
    
    // MARK: - Memory Caching Methods
    func preloadSongToMemory(_ song: Song, for trackId: String) async {
        await repository.preloadSongToMemory(song, for: trackId)
    }
    
    func isTrackCachedInMemory(trackId: String) -> Bool {
        return repository.isTrackCachedInMemory(trackId: trackId)
    }
}
