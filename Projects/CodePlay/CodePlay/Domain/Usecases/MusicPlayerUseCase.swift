//
//  File.swift
//  CodePlay
//
//  Created by 신얀 on 7/15/25.
//

import Foundation
import MusicKit

// MARK: - Music Player Use Case Protocol
protocol MusicPlayerUseCase {
    /// 30초 미리듣기 재생 (비즈니스 로직)
    func playPreview(trackId: String) async
    
    /// 미리듣기 정지
    func stopPreview() async
    
    /// 미리듣기 토글 (재생/정지 판단 로직)
    func togglePreview(for trackId: String) async
    
    /// 현재 재생 상태 조회
    func getCurrentPlayingTrackId() -> String?
    func getIsPlaying() -> Bool
    func getPlaybackProgress() -> Double
    
    /// 상태 변경 콜백 설정 (ViewModel과의 연결)
    func setOnPlaybackStateChanged(_ callback: @escaping (String?, Bool) -> Void)
    func setOnProgressChanged(_ callback: @escaping (Double) -> Void)
    
    /// 음악 캐싱 관련 메서드들
    func cacheSong(_ song: Song, for trackId: String)
    func preloadSongToMemory(_ song: Song, for trackId: String) async
}


// MARK: - DefaultMusicPlayerUseCase
final class DefaultMusicPlayerUseCase: MusicPlayerUseCase {
    private let repository: MusicPlayerRepository
    
    // MARK: - Timer 및 Progress 관리 (비즈니스 로직)
    private var progressTimer: DispatchSourceTimer?
    private var playbackStartTime: Date?
    private var _playbackProgress: Double = 0.0
    private let totalDuration: TimeInterval = 30.0
    
    // MARK: - 콜백 (ViewModel과의 연결)
    private var onPlaybackStateChanged: ((String?, Bool) -> Void)?
    private var onProgressChanged: ((Double) -> Void)?
    
    init(repository: MusicPlayerRepository) {
        self.repository = repository
    }
    
    // MARK: - 상태 조회 메서드
    func getCurrentPlayingTrackId() -> String? {
        return repository.getCurrentPlayingStatus().trackId
    }
    
    func getIsPlaying() -> Bool {
        return repository.getCurrentPlayingStatus().isPlaying
    }
    
    func getPlaybackProgress() -> Double {
        return _playbackProgress
    }
    
    // MARK: - 콜백 설정
    func setOnPlaybackStateChanged(_ callback: @escaping (String?, Bool) -> Void) {
        self.onPlaybackStateChanged = callback
    }
    
    func setOnProgressChanged(_ callback: @escaping (Double) -> Void) {
        self.onProgressChanged = callback
    }
    
    // MARK: - 30초 미리듣기 비즈니스 로직
    func playPreview(trackId: String) async {
        // 이전 곡 정지
        await stopPreview()
        
        do {
            try await repository.playTrack(trackId: trackId)
            playbackStartTime = Date()
            startProgressTimer()
            notifyStateChange()
        } catch {
            notifyStateChange()
        }
    }
    
    func stopPreview() async {
        stopProgressTimer()
        playbackStartTime = nil
        resetProgress()
        await repository.stopTrack()
        notifyStateChange()
    }
    
    func togglePreview(for trackId: String) async {
        let status = repository.getCurrentPlayingStatus()
        
        if status.trackId == trackId && status.isPlaying {
            await repository.pauseTrack()
            stopProgressTimer()
        } else {
            await playPreview(trackId: trackId)
        }
        notifyStateChange()
    }
    
    // MARK: - Private Progress Management (비즈니스 로직)
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
        
        // 30초 완료 시 자동 정지 (비즈니스 규칙)
        if progress >= 1.0 {
            Task {
                await stopPreview()
            }
        }
    }
    
    private func notifyStateChange() {
        let status = repository.getCurrentPlayingStatus()
        onPlaybackStateChanged?(status.trackId, status.isPlaying)
    }
    
    private func resetProgress() {
        _playbackProgress = 0.0
        onProgressChanged?(0.0)
    }
    
    /// 음악 캐싱 관련 메서드들
    func cacheSong(_ song: Song, for trackId: String) {
        repository.cacheSong(song, for: trackId)
    }
    
    func preloadSongToMemory(_ song: Song, for trackId: String) async {
        await repository.preloadSongToMemory(song, for: trackId)
    }
}
