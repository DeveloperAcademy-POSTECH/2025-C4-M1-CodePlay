

import Foundation

// MARK: - Music Player Use Case Protocol
protocol MusicPlayerUseCase {
    /// 30초 미리듣기 재생 시작
    func playPreview(trackId: String) async
    
    /// 미리듣기 일시정지
    func pausePreview() async
    
    /// 미리듣기 정지
    func stopPreview() async
    
    /// 미리듣기 재생/일시정지 토글
    func togglePreview(for trackId: String) async
    
    /// 현재 재생 상태 조회
    var currentPlayingTrackId: String? { get }
    var isPlaying: Bool { get }
    
    /// 재생 진행률 (0.0 ~ 1.0, 30초 기준)
    var playbackProgress: Double { get }
    
    /// 재생 상태 변경 알림을 위한 클로저
    var onPlaybackStateChanged: ((String?, Bool) -> Void)? { get set }
    
    /// 진행률 변경 알림을 위한 클로저
    var onProgressChanged: ((Double) -> Void)? { get set }
}

// MARK: - Default Music Player Use Case Implementation
final class DefaultMusicPlayerUseCase: MusicPlayerUseCase {
    private let repository: MusicPlayerRepository
    private var autoStopTask: Task<Void, Never>?
    private var progressTimer: DispatchSourceTimer?
    private var playbackStartTime: Date?
    private let totalDuration: TimeInterval = 30.0 // 30초
    
    var onPlaybackStateChanged: ((String?, Bool) -> Void)?
    var onProgressChanged: ((Double) -> Void)?
    
    private var _playbackProgress: Double = 0.0
    var playbackProgress: Double {
        return _playbackProgress
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
        do {
            // 이전 곡 중지
            await stopPreview()
            
            // 새 곡 재생
            try await repository.playTrack(trackId: trackId)
            
            // 재생 시작 시간 기록
            playbackStartTime = Date()
            
            // 상태 변경 알림
            notifyStateChange()
            
            // 진행률 타이머 시작
            startProgressTimer()
            
            // 30초 후 자동 정지 (비즈니스 규칙)
            setupAutoStop(for: trackId)
            
            print("🎵 재생 시작: \(trackId)")
            
        } catch {
            print("❌ 재생 실패: \(error.localizedDescription)")
            notifyStateChange()
        }
    }
    
    func pausePreview() async {
        do {
            try await repository.pauseTrack()
            stopProgressTimer() // 일시정지 시 타이머 중지
            notifyStateChange()
            print("⏸️ 일시정지")
        } catch {
            print("❌ 일시정지 실패: \(error.localizedDescription)")
        }
    }
    
    func stopPreview() async {
        // 자동 정지 태스크 취소
        autoStopTask?.cancel()
        autoStopTask = nil
        
        // 진행률 타이머 중지
        stopProgressTimer()
        
        // 진행률 초기화
        updateProgress(0.0)
        
        do {
            try await repository.stopTrack()
            notifyStateChange()
            print("⏹️ 재생 중지")
        } catch {
            print("❌ 중지 실패: \(error.localizedDescription)")
        }
    }
    
    func togglePreview(for trackId: String) async {
        let status = repository.getCurrentPlayingStatus()
        
        if status.trackId == trackId && status.isPlaying {
            // 같은 곡이 재생 중이면 일시정지
            await pausePreview()
        } else if status.trackId == trackId && !status.isPlaying {
            // 같은 곡이 일시정지된 상태면 재개
            do {
                try await repository.playTrack(trackId: trackId)
                notifyStateChange()
                startProgressTimer() // 타이머 재시작
                print("▶️ 재생 재개")
            } catch {
                print("❌ 재생 재개 실패: \(error.localizedDescription)")
            }
        } else {
            // 다른 곡이거나 처음 재생이면 새로 재생 시작
            await playPreview(trackId: trackId)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAutoStop(for trackId: String) {
        autoStopTask = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000) // 30초
            
            // 태스크가 취소되지 않았고, 여전히 같은 곡이 재생 중이면 정지
            if !Task.isCancelled,
               repository.getCurrentPlayingStatus().trackId == trackId {
                await stopPreview()
            }
        }
    }
    
    private func startProgressTimer() {
        stopProgressTimer() // 기존 타이머 정리
        print("🔥 [MusicPlayerUseCase] 타이머 시작!")
        
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100))
        timer.setEventHandler { [weak self] in
            self?.updateProgressFromTimer()
        }
        timer.resume()
        
        progressTimer = timer
        print("🔥 [MusicPlayerUseCase] DispatchSourceTimer 설정 완료!")
    }
    
    private func stopProgressTimer() {
        progressTimer?.cancel()
        progressTimer = nil
        print("🔥 [MusicPlayerUseCase] 타이머 정지!")
    }
    
    private func updateProgressFromTimer() {
        guard let startTime = playbackStartTime else { 
            print("❌ [MusicPlayerUseCase] playbackStartTime이 nil!")
            return 
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = min(elapsed / totalDuration, 1.0) // 최대 1.0
        
        print("🔥 [MusicPlayerUseCase] 경과시간: \(elapsed)초, 진행률: \(progress)")
        
        updateProgress(progress)
        
        // 30초 완료 시 자동 정지
        if progress >= 1.0 {
            print("✅ [MusicPlayerUseCase] 30초 완료! 자동 정지")
            Task {
                await stopPreview()
            }
        }
    }
    
    private func updateProgress(_ progress: Double) {
        _playbackProgress = progress
        print("🔥 [MusicPlayerUseCase] 진행률 업데이트: \(progress)")
        DispatchQueue.main.async {
            self.onProgressChanged?(progress)
        }
    }
    
    private func notifyStateChange() {
        let status = repository.getCurrentPlayingStatus()
        onPlaybackStateChanged?(status.trackId, status.isPlaying)
    }
} 
