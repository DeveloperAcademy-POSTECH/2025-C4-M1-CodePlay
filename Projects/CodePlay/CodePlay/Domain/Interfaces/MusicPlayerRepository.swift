

import Foundation
import MusicKit
import AVFoundation

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
    
    // MARK: - Caching Methods
    /// 캐싱된 Song으로 즉시 미리듣기 재생
    /// - Parameter song: 캐싱된 Song 객체
    func playPreviewFromCache(song: Song) async
    
    /// 캐싱된 Song 저장
    /// - Parameters:
    ///   - song: 캐싱할 Song 객체
    ///   - trackId: 트랙 ID
    func storeCachedSong(_ song: Song, for trackId: String)
    
    /// 캐싱된 Song 조회
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 캐싱된 Song 객체 (없으면 nil)
    func getCachedSong(for trackId: String) -> Song?
    
    // MARK: - Enhanced Playback Control
    /// 현재 로드된 곡을 재개
    func resumeCurrentTrack() async throws
    
    // MARK: - Memory Caching Methods
    /// Song의 Preview URL을 메모리에 프리로드
    /// - Parameters:
    ///   - song: MusicKit Song 객체
    ///   - trackId: 트랙 ID
    func preloadSongToMemory(_ song: Song, for trackId: String) async
    
    /// 메모리에서 즉시 재생 (최고 성능)
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 메모리에서 즉시 재생되었는지 여부
    func playFromMemoryCache(trackId: String) async -> Bool
    
    /// 메모리 캐시 상태 확인
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 메모리에 캐싱되어 있는지 여부
    func isTrackCachedInMemory(trackId: String) -> Bool
}

// MARK: - Default Music Player Repository Implementation
final class DefaultMusicPlayerRepository: MusicPlayerRepository {
    private let player = ApplicationMusicPlayer.shared
    private var currentTrackId: String?
    private var isCurrentlyPlaying: Bool = false
    
    // MARK: - Caching Properties
    /// 캐싱된 Song 객체들을 저장하는 딕셔너리
    private var songCache: [String: Song] = [:]
    
    /// 메모리 오디오 매니저 (즉시 재생용)
    private let memoryAudioManager = MemoryAudioManager.shared
    
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
    private var pausedElapsed: TimeInterval = 0.0  // 일시정지 시점의 경과 시간
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
            pausedElapsed = 0.0  // 새 곡 시작 시 초기화
            startProgressTimer() // 이 타이머가 30초 후 자동 정지까지 처리
            notifyStateChange()
        } catch {
            print("❌ 미리듣기 재생 실패: \(trackId)")
            notifyStateChange()
        }
    }
    
    func pausePreview() async {
        // 1차: 메모리 매니저에서 재생 중인지 확인하고 일시정지
        let memoryStatus = memoryAudioManager.getCurrentPlayingStatus()
        if memoryStatus.isPlaying {
            memoryAudioManager.pausePlayback()
            isCurrentlyPlaying = false
            print("⏸️ 메모리 매니저에서 일시정지 완료")
            return
        }
        
        // 2차: 기존 MusicKit 플레이어 일시정지
        do {
            try await pauseTrack()
            stopProgressTimer()
            
            // 일시정지 시점의 경과 시간 기록
            if let startTime = playbackStartTime {
                pausedElapsed = Date().timeIntervalSince(startTime)
            }
            
            notifyStateChange()
            print("⏸️ MusicKit 플레이어 일시정지 완료 (경과: \(String(format: "%.1f", pausedElapsed))초)")
        } catch {
            print("❌ 일시정지 실패: \(error)")
        }
    }
    
    func stopPreview() async {
        stopProgressTimer()
        playbackStartTime = nil  // 시작 시간 초기화
        pausedElapsed = 0.0      // 일시정지 경과 시간 초기화
        resetProgress()
        
        do {
            try await stopTrack()
        } catch {
            print("❌ 정지 실패: \(error)")
        }
        
        notifyStateChange()
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
        guard let startTime = playbackStartTime else { 
            stopProgressTimer()
            return 
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = min(elapsed / totalDuration, 1.0)
        
        _playbackProgress = progress
        onProgressChanged?(progress)
        
        // 30초 완료 시 자동 정지
        if progress >= 1.0 {
            Task { 
                await stopPreview()
            }
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
    
    // MARK: - Caching Implementation
    func playPreviewFromCache(song: Song) async {
        // 이전 곡 정지
        await stopPreview()
        
        // 캐싱된 Song으로 즉시 재생
        player.queue = [song]
        do {
            try await player.play()
            currentTrackId = song.id.rawValue
            isCurrentlyPlaying = true
            playbackStartTime = Date()
            pausedElapsed = 0.0  // 새 곡 시작 시 초기화
            startProgressTimer()
            notifyStateChange()
            
            print("🚀 캐시에서 즉시 재생: \(song.title)")
        } catch {
            print("❌ 캐시 재생 실패: \(error)")
        }
    }
    
    func storeCachedSong(_ song: Song, for trackId: String) {
        songCache[trackId] = song
        print("💾 Song 캐싱 완료: \(song.title) (ID: \(trackId))")
    }
    
    func getCachedSong(for trackId: String) -> Song? {
        return songCache[trackId]
    }
    
    // MARK: - Enhanced Playback Control
    func resumeCurrentTrack() async throws {
        guard let currentTrackId = currentTrackId else {
            throw MusicPlayerError.noTrackLoaded
        }
        
        // 1차: 메모리 매니저에서 재개 시도
        let memoryStatus = memoryAudioManager.getCurrentPlayingStatus()
        if memoryStatus.trackId == currentTrackId && !memoryStatus.isPlaying {
            let resumeSuccess = memoryAudioManager.resumePlayback()
            if resumeSuccess {
                isCurrentlyPlaying = true
                print("🔄 메모리 매니저에서 재개: \(currentTrackId)")
                return
            }
        }
        
        // 2차: 기존 MusicKit 플레이어 재개
        try await player.play()
        isCurrentlyPlaying = true
        
        // 일시정지된 시점부터 재개하도록 시작 시간 조정
        if pausedElapsed > 0 {
            playbackStartTime = Date().addingTimeInterval(-pausedElapsed)
            startProgressTimer()
        } else if playbackStartTime != nil {
            startProgressTimer()
        }
        
        notifyStateChange()
        print("🔄 MusicKit 플레이어에서 재개: \(currentTrackId) (경과: \(String(format: "%.1f", pausedElapsed))초)")
    }
    
    // MARK: - Memory Caching Methods
    func preloadSongToMemory(_ song: Song, for trackId: String) async {
        // Song 객체도 함께 캐싱
        storeCachedSong(song, for: trackId)
        
        // Preview URL에서 메모리로 오디오 프리로드
        if let previewURL = song.previewAssets?.first?.url {
            await memoryAudioManager.preloadAudioToMemory(from: previewURL, trackId: trackId)
        } else {
            print("❌ Preview URL 없음: \(song.title) (ID: \(trackId))")
        }
    }
    
    func playFromMemoryCache(trackId: String) async -> Bool {
        print("🚀 빠른 재생 시도: \(trackId)")
        
        // 1차: 캐싱된 Song으로 즉시 MusicKit 재생 (가장 안정적)
        if let cachedSong = getCachedSong(for: trackId) {
            // 이전 재생 정지
            await stopPreview()
            
            // 캐싱된 Song으로 즉시 재생
            player.queue = [cachedSong]
            do {
                try await player.play()
                currentTrackId = trackId
                isCurrentlyPlaying = true
                playbackStartTime = Date()
                pausedElapsed = 0.0
                startProgressTimer()
                notifyStateChange()
                
                print("⚡ Song 캐시에서 즉시 재생: \(cachedSong.title)")
                return true
            } catch {
                print("❌ Song 캐시 재생 실패: \(error)")
            }
        }
        
        // 2차: 메모리 오디오 시도 (실험적)
        let memoryPlaySuccess = memoryAudioManager.playFromMemoryCache(trackId: trackId)
        if memoryPlaySuccess {
            currentTrackId = trackId
            isCurrentlyPlaying = true
            
            // 콜백 연결
            memoryAudioManager.onPlaybackStateChanged = { [weak self] trackId, isPlaying in
                self?.currentTrackId = trackId
                self?.isCurrentlyPlaying = isPlaying
                self?.onPlaybackStateChanged?(trackId, isPlaying)
            }
            
            memoryAudioManager.onProgressChanged = { [weak self] progress in
                self?._playbackProgress = progress
                self?.onProgressChanged?(progress)
            }
            
            print("⚡ 메모리에서 재생 성공: \(trackId)")
            return true
        }
        
        print("❌ 모든 캐시에서 재생 실패: \(trackId)")
        return false
    }
    
    func isTrackCachedInMemory(trackId: String) -> Bool {
        return memoryAudioManager.isTrackCachedInMemory(trackId: trackId)
    }
}
