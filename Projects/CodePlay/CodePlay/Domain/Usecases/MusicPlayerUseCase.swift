

import Foundation

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
}
