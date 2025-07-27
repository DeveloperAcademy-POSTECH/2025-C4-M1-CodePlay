//
//  MemoryAudioCache.swift
//  CodePlay
//
//  Created by AI Assistant on 1/27/25.
//

import Foundation
import AVFoundation
import MusicKit

// MARK: - Memory Audio Cache Model  
/// 메모리에 캐싱된 오디오 정보
struct CachedAudioAsset {
    let trackId: String
    let previewURL: URL
    let isLoaded: Bool
    let cachedData: Data?
    
    static func loaded(trackId: String, url: URL, data: Data) -> CachedAudioAsset {
        return CachedAudioAsset(
            trackId: trackId,
            previewURL: url,
            isLoaded: true,
            cachedData: data
        )
    }
    
    static func failed(trackId: String, url: URL) -> CachedAudioAsset {
        return CachedAudioAsset(
            trackId: trackId,
            previewURL: url,
            isLoaded: false,
            cachedData: nil
        )
    }
}

// MARK: - Memory Audio Manager
/// AVPlayer 기반 메모리 캐싱 및 즉시 재생 관리자
final class MemoryAudioManager {
    static let shared = MemoryAudioManager()
    
    // MARK: - Properties
    private var memoryCache: [String: CachedAudioAsset] = [:]
    private var avPlayer: AVPlayer?
    
    // 재생 상태 관리
    private var currentTrackId: String?
    private var isCurrentlyPlaying: Bool = false
    private var playbackStartTime: Date?
    private var pausedTime: TimeInterval = 0
    
    // 콜백
    var onPlaybackStateChanged: ((String?, Bool) -> Void)?
    var onProgressChanged: ((Double) -> Void)?
    
    // 30초 타이머
    private var progressTimer: DispatchSourceTimer?
    private let previewDuration: TimeInterval = 30.0
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("🎵 AVAudioSession 설정 완료")
        } catch {
            print("❌ AVAudioSession 설정 실패: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    /// Preview URL에서 오디오 데이터를 메모리로 프리로드
    /// - Parameters:
    ///   - previewURL: 미리듣기 URL
    ///   - trackId: 트랙 ID
    func preloadAudioToMemory(from previewURL: URL, trackId: String) async {
        print("🔄 메모리 캐싱 시작: \(trackId) - \(previewURL)")
        
        do {
            // URL에서 오디오 데이터 다운로드
            let (data, response) = try await URLSession.shared.data(from: previewURL)
            
            print("📥 다운로드 완료: \(trackId) - \(data.count) bytes")
            
            // HTTP 응답 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 HTTP 상태: \(httpResponse.statusCode) for \(trackId)")
                
                if httpResponse.statusCode == 200 {
                    // 메모리 캐시에 저장
                    let cachedAsset = CachedAudioAsset.loaded(
                        trackId: trackId,
                        url: previewURL,
                        data: data
                    )
                    memoryCache[trackId] = cachedAsset
                    
                    print("🚀 메모리 캐싱 성공: \(trackId) (\(data.count) bytes)")
                } else {
                    print("❌ HTTP 상태 오류: \(httpResponse.statusCode) for \(trackId)")
                    memoryCache[trackId] = .failed(trackId: trackId, url: previewURL)
                }
            } else {
                print("❌ HTTP 응답 파싱 실패: \(trackId)")
                memoryCache[trackId] = .failed(trackId: trackId, url: previewURL)
            }
            
        } catch {
            print("❌ 메모리 캐싱 실패: \(trackId) - \(error.localizedDescription)")
            print("🔍 상세 오류: \(error)")
            memoryCache[trackId] = .failed(trackId: trackId, url: previewURL)
        }
    }
    
    /// 메모리에서 즉시 재생
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 메모리에서 즉시 재생되었는지 여부
    func playFromMemoryCache(trackId: String) -> Bool {
        print("🎵 메모리 재생 시도: \(trackId)")
        
        guard let cachedAsset = memoryCache[trackId] else {
            print("❌ 메모리 캐시에 없음: \(trackId)")
            return false
        }
        
        guard cachedAsset.isLoaded else {
            print("❌ 로드 실패된 캐시: \(trackId)")
            return false
        }
        
        guard let audioData = cachedAsset.cachedData else {
            print("❌ 오디오 데이터 없음: \(trackId)")
            return false
        }
        
        print("📊 오디오 데이터 크기: \(audioData.count) bytes for \(trackId)")
        
        // 이전 재생 정지
        stopPlayback()
        
        do {
            // 임시 파일로 데이터 저장
            let tempURL = try createTempAudioFile(from: audioData, trackId: trackId)
            print("📁 임시 파일 생성: \(tempURL.path)")
            
            // AVPlayer로 즉시 재생
            avPlayer = AVPlayer(url: tempURL)
            
            // 플레이어 상태 확인
            guard let player = avPlayer else {
                print("❌ AVPlayer 생성 실패: \(trackId)")
                return false
            }
            
            player.play()
            
            // 상태 업데이트
            currentTrackId = trackId
            isCurrentlyPlaying = true
            playbackStartTime = Date()
            pausedTime = 0
            
            // 30초 타이머 시작
            startProgressTimer()
            notifyStateChange()
            
            print("⚡ 메모리에서 재생 성공: \(trackId)")
            
            // 재생 상태 모니터링
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let item = player.currentItem {
                    print("🎼 플레이어 아이템 상태: \(item.status.rawValue) for \(trackId)")
                    if let error = item.error {
                        print("❌ 플레이어 아이템 오류: \(error.localizedDescription)")
                    }
                }
            }
            
            return true
            
        } catch {
            print("❌ 메모리 재생 실패: \(trackId) - \(error.localizedDescription)")
            print("🔍 재생 오류 상세: \(error)")
            return false
        }
    }
    
    /// 재생 일시정지
    func pausePlayback() {
        guard isCurrentlyPlaying else { return }
        
        // 현재 재생 시간 기록
        if let startTime = playbackStartTime {
            pausedTime = Date().timeIntervalSince(startTime)
        }
        
        avPlayer?.pause()
        isCurrentlyPlaying = false
        stopProgressTimer()
        
        notifyStateChange()
        print("⏸️ 메모리 재생 일시정지")
    }
    
    /// 재생 재개
    func resumePlayback() -> Bool {
        guard let trackId = currentTrackId,
              let cachedAsset = memoryCache[trackId],
              cachedAsset.isLoaded,
              !isCurrentlyPlaying else {
            return false
        }
        
        // 일시정지된 위치부터 재개
        if let player = avPlayer {
            let seekTime = CMTime(seconds: pausedTime, preferredTimescale: 1000)
            player.seek(to: seekTime)
            player.play()
            
            isCurrentlyPlaying = true
            
            // 일시정지된 시점을 고려하여 시작 시간 조정
            playbackStartTime = Date().addingTimeInterval(-pausedTime)
            
            startProgressTimer()
            notifyStateChange()
            
            print("▶️ 메모리 재생 재개 (위치: \(String(format: "%.1f", pausedTime))초)")
            return true
        }
        
        return false
    }
    
    /// 재생 정지
    func stopPlayback() {
        avPlayer?.pause()
        avPlayer = nil
        isCurrentlyPlaying = false
        currentTrackId = nil
        playbackStartTime = nil
        pausedTime = 0
        
        stopProgressTimer()
        notifyStateChange()
    }
    
    /// 현재 재생 상태
    func getCurrentPlayingStatus() -> (trackId: String?, isPlaying: Bool) {
        return (currentTrackId, isCurrentlyPlaying)
    }
    
    /// 메모리 캐시에 있는지 확인
    func isTrackCachedInMemory(trackId: String) -> Bool {
        return memoryCache[trackId]?.isLoaded == true
    }
    
    // MARK: - Private Methods
    
    private func createTempAudioFile(from data: Data, trackId: String) throws -> URL {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("audio_\(trackId)")
            .appendingPathExtension("m4a")
        
        try data.write(to: tempURL)
        
        // 60초 후 임시 파일 자동 정리
        DispatchQueue.global().asyncAfter(deadline: .now() + 60) {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        return tempURL
    }
    
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
        let progress = min(elapsed / previewDuration, 1.0)
        
        onProgressChanged?(progress)
        
        // 30초 완료 시 자동 정지
        if progress >= 1.0 {
            onPlaybackComplete()
        }
    }
    
    private func onPlaybackComplete() {
        stopPlayback()
        print("✅ 30초 미리듣기 완료")
    }
    
    private func notifyStateChange() {
        onPlaybackStateChanged?(currentTrackId, isCurrentlyPlaying)
    }
} 