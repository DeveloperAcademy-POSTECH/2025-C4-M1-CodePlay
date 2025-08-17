import Foundation
internal import Combine

// MARK: - Input
protocol MusicPlayerViewModelInput {
    func playPreview(trackId: String)
    func stopPreview()
    func togglePreview(for trackId: String)
    func deletePlaylistEntry(trackId: String)
}

// MARK: - Output
protocol MusicPlayerViewModelOutput {
    var currentlyPlayingTrackId: Observable<String?> { get }
    var isPlaying: Observable<Bool> { get }
    var playbackProgress: Observable<Double> { get }
}

// MARK: - MusicPlayerViewModel
protocol MusicPlayerViewModel: MusicPlayerViewModelInput, MusicPlayerViewModelOutput, ObservableObject {}

// MARK: - Implementation
final class DefaultMusicPlayerViewModel: MusicPlayerViewModel {
    // MARK: Output (프레젠테이션 상태)
    var currentlyPlayingTrackId: Observable<String?> = Observable(nil)
    var isPlaying: Observable<Bool> = Observable(false)
    var playbackProgress: Observable<Double> = Observable(0.0)
    
    private let musicPlayerUseCase: MusicPlayerUseCase
    
    // MARK: Init
    init(musicPlayerUseCase: MusicPlayerUseCase) {
        self.musicPlayerUseCase = musicPlayerUseCase
        setupCallbacks()
    }
    
    // MARK: - UseCase 콜백 설정 (프레젠테이션 로직)
    private func setupCallbacks() {
        musicPlayerUseCase.setOnPlaybackStateChanged { [weak self] trackId, isPlaying in
            DispatchQueue.main.async {
                self?.currentlyPlayingTrackId.value = trackId
                self?.isPlaying.value = isPlaying
            }
        }
        
        musicPlayerUseCase.setOnProgressChanged { [weak self] progress in
            DispatchQueue.main.async {
                self?.playbackProgress.value = progress
            }
        }
    }
    
    // MARK: Input (UseCase 호출 및 UI 상태 관리)
    func playPreview(trackId: String) {
        Task {
            await musicPlayerUseCase.playPreview(trackId: trackId)
        }
    }
    
    func stopPreview() {
        Task {
            await musicPlayerUseCase.stopPreview()
        }
    }
    
    func togglePreview(for trackId: String) {
        Task {
            await musicPlayerUseCase.togglePreview(for: trackId)
        }
    }
    
    func deletePlaylistEntry(trackId: String) {
        // UI 로직: 현재 재생 중인 곡이면 정지
        if musicPlayerUseCase.getCurrentPlayingTrackId() == trackId {
            stopPreview()
        }
    }
}
