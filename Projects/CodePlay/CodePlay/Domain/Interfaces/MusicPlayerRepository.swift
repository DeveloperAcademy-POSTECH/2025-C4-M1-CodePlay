

import Foundation
import MusicKit

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
    
    /// 30초 미리듣기 (자동 정지 + 진행률 추적 포함)
    func playPreview(trackId: String) async
    
    /// 미리듣기 일시정지
    func pausePreview() async
    
    /// 미리듣기 정지 (진행률 초기화 포함)
    func stopPreview() async
    
    /// 미리듣기 토글 (재생/일시정지 자동 판단)
    func togglePreview(for trackId: String) async
    
    /// 현재 재생 진행률 조회 (0.0 ~ 1.0)
    var playbackProgress: Double { get }
    
    /// 진행률 변경 콜백 설정
    var onProgressChanged: ((Double) -> Void)? { get set }
    
    /// 재생 상태 변경 콜백 설정
    var onPlaybackStateChanged: ((String?, Bool) -> Void)? { get set }
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
    
    // MARK: - Preview 기능 및 진행률 관리
    private var _playbackProgress: Double = 0.0
    private var progressTimer: DispatchSourceTimer?
    private var playbackStartTime: Date?
    private let totalDuration: TimeInterval = 30.0
    
    var playbackProgress: Double {
        return _playbackProgress
    }
    
    var onProgressChanged: ((Double) -> Void)?
    var onPlaybackStateChanged: ((String?, Bool) -> Void)?
    
    func playPreview(trackId: String) async {
        // 이전 곡 정지
        await stopPreview()
        
        do {
            try await playTrack(trackId: trackId)
            playbackStartTime = Date()
            startProgressTimer()
            notifyStateChange()
            
            // 30초 후 자동 정지
            Task {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                await stopPreview()
            }
        } catch {
         
            notifyStateChange()
        }
    }
    
    func pausePreview() async {
        withNotifyStateChange {
            try? await self.pauseTrack()
            self.stopProgressTimer()
        }
    }
    
    func stopPreview() async {
        withNotifyStateChange {
            self.stopProgressTimer()
            self.resetProgress()
            try? await self.stopTrack()
        }
    }
    
    func togglePreview(for trackId: String) async {
        let status = getCurrentPlayingStatus()
        
        if status.trackId == trackId && status.isPlaying {
            await pausePreview()
        } else {
            await playPreview(trackId: trackId)
        }
    }
    
    // MARK: - Private Methods
    private func startProgressTimer() {
        stopProgressTimer()
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            self?.updateProgress()
        }
        timer.resume()
        progressTimer = timer
    }
    
    private func stopProgressTimer() {
        progressTimer?.cancel()
        progressTimer = nil
    }
    
    private func updateProgress() {
        guard let startTime = playbackStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = min(elapsed / totalDuration, 1.0)
        
        _playbackProgress = progress
        onProgressChanged?(progress)
        
        if progress >= 1.0 {
            Task { await stopPreview() }
        }
    }
    
    private func notifyStateChange() {
        let status = getCurrentPlayingStatus()
        onPlaybackStateChanged?(status.trackId, status.isPlaying)
    }

    private func resetProgress() {
        _playbackProgress = 0.0
        onProgressChanged?(0.0)
    }

    private func withNotifyStateChange(_ block: @escaping () async -> Void) {
        Task {
            await block()
            notifyStateChange()
        }
    }
}
