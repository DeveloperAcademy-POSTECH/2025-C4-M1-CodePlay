//
//  AppleMusicConnectView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

internal import Combine
import MusicKit
import SwiftUI

struct AppleMusicConnectView: View {
    @EnvironmentObject var viewModelWrapper: MusicViewModelWrapper
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단 여백 (Safe Area 고려하여 조정)
            Spacer().frame(height: 96)

            if viewModelWrapper.authorizationStatus?.status == .denied {
                Image("Linkfail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            } else {
                Image("Linkapplemusic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            }

            // 사각형과 제목 사이 간격
            Spacer().frame(height: 32)

            VStack(spacing : 12){
                Text("Apple Music을\n연결해주세요")
                    .font(.HlgBold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.neu900)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("페스티벌 플레이리스트 생성을 위해\nApple Music을 연결해주세요.")
                    .font(.BmdRegular())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.neu700)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // 4. 연결 버튼 또는 설정 안내 (하단에서 적절한 위치에 배치)
            if viewModelWrapper.authorizationStatus?.status == .denied {
                // 권한 거부 시 설정 안내
                VStack(spacing: 16) {
                    Text("설정에서 권한을 허용해주세요")
                        .font(Font.custom("KoddiUD OnGothic", size: 18))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    BottomButton(title: "설정으로 이동", kind: .line) {
                        viewModelWrapper.appleMusicConnectViewModel.shouldOpenSettings.value = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.horizontal, 16)
                }
            } else {
                BottomButton(
                    title: "Apple Music에 연결",
                    kind: .line,
                    action: {
                        Task {
                            // 권한 요청
                            viewModelWrapper.appleMusicConnectViewModel.shouldRequestMusicAuthorization.value = true
                        }
                    }
                )
                .padding(.horizontal, 16)
            }

            // 에러 메시지 표시
            if let errorMessage = viewModelWrapper.errorMessage {
                Text(errorMessage)
                    .font(.BmdRegular())
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)
            }

            // 하단 여백 (Home Indicator 고려)
            Spacer().frame(height: 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .bottom)  // 하단 Safe Area 무시
    }
}

// MARK: - ViewModelWrapper for ObservableObject compatibility
final class MusicViewModelWrapper: ObservableObject {
    @Published var authorizationStatus: MusicAuthorizationStatusModel?
    @Published var subscriptionStatus: MusicSubscriptionModel?
    @Published var errorMessage: String?
    @Published var canPlayMusic: Bool = false
    @Published var artistCandidates: [String] = []
    /// 현재 프로세스 단계 (0: 대기, 1: 아티스트 탐색 시작, 2: 아티스트 탐색 완료, 3: 인기곡 추출 완료)
    @Published var progressStep: Int = 0
    /// 플레이리스트 생성 완료 후 MadePlaylistView로의 네비게이션 트리거
    @Published var navigateToMadePlaylist: Bool = false
    /// Apple Music으로 내보내기 중인지 여부
    @Published var isExporting: Bool = false
    /// Apple Music 내보내기 완료 여부
    @Published var isExportCompleted: Bool = false
    /// 완성된 플레이리스트 엔트리 목록
    @Published var playlistEntries: [PlaylistEntry] = []
    /// 현재 재생 중인 곡의 ID (30초 미리듣기용)
    @Published var currentlyPlayingTrackId: String?
    /// 재생 상태 (재생 중/일시정지)
    @Published var isPlaying: Bool = false
    /// 재생 진행률 (0.0 ~ 1.0, 30초 기준)
    @Published var playbackProgress: Double = 0.0
    @Published var isLoading: Bool = true  // 로딩 상태 추가
    @Published var festivalData: DynamoDataItem? = nil


    var appleMusicConnectViewModel: any AppleMusicConnectViewModel
    var exportViewModelWrapper: any ExportPlaylistViewModel
    var festivalCheckViewModel: any FestivalCheckViewModel

    /// MusicPlayer UseCase (Clean Architecture 적용)
    private var musicPlayerUseCase: MusicPlayerUseCase

    init(appleMusicConnectViewModel: any AppleMusicConnectViewModel, exportViewModelWrapper: any ExportPlaylistViewModel, festivalCheckViewModel: any FestivalCheckViewModel, musicPlayerUseCase: MusicPlayerUseCase) {
        self.appleMusicConnectViewModel = appleMusicConnectViewModel
        self.exportViewModelWrapper = exportViewModelWrapper
        self.festivalCheckViewModel = festivalCheckViewModel
        self.musicPlayerUseCase = musicPlayerUseCase
        

        // UseCase를 통해 Repository 콜백 설정
        self.musicPlayerUseCase.setupRepositoryCallbacks(
            onPlaybackStateChanged: { [weak self] trackId, isPlaying in
                DispatchQueue.main.async {
                    self?.currentlyPlayingTrackId = trackId
                    self?.isPlaying = isPlaying
                }
            },
            onProgressChanged: { [weak self] progress in
                print("🎯 [MusicViewModelWrapper] 진행률 받음: \(progress)")
                DispatchQueue.main.async {
                    self?.playbackProgress = progress
                    print("🎯 [MusicViewModelWrapper] UI 진행률 업데이트 완료: \(self?.playbackProgress ?? 0)")
                }
            }
        )
        
        festivalCheckViewModel.isLoading.observe(on: self) { [weak self] newData in
            self?.isLoading = newData
        }
        
        festivalCheckViewModel.festivalData.observe(on: self) { [weak self] newData in
            self?.festivalData = newData
        }

        appleMusicConnectViewModel.authorizationStatus.observe(on: self) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                
                if status?.status == .authorized {
                    self?.canPlayMusic = true
                } else {
                    self?.canPlayMusic = false
                }
            }
        }

        appleMusicConnectViewModel.subscriptionStatus.observe(on: self) { [weak self] subscription in
            DispatchQueue.main.async {
                self?.subscriptionStatus = subscription
            }
        }

        appleMusicConnectViewModel.errorMessage.observe(on: self) { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error
            }
        }

        appleMusicConnectViewModel.canPlayMusic.observe(on: self) { [weak self] canPlay in
            DispatchQueue.main.async {
                self?.canPlayMusic = canPlay
            }
        }
        
        exportViewModelWrapper.artistCandidates.observe(on: self) { [weak self] candidates in
            self?.artistCandidates = candidates
        }
    }
    /// View가 나타날 때 호출되는 함수
    /// - OCR로부터 받은 RawText를 바탕으로 전체 흐름 수행
    func onAppear(with rawText: RawText?) {
        guard let rawText else { return }

        progressStep = 0

        // 1단계: 텍스트 전처리 (후보 아티스트 추출)
        exportViewModelWrapper.preProcessRawText(rawText)
        withAnimation(.easeInOut(duration: 0.5)) {
            progressStep = 1
        }

        Task {
            // 2단계: 아티스트 검색
            let matches = await exportViewModelWrapper.searchArtists(from: rawText)
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.progressStep = 2
                }
                matches.forEach { print("✅ \( $0.artistName ) (\($0.appleMusicId))") }
            }

            // 3단계: 아티스트별 상위 곡 검색
            let songs = await exportViewModelWrapper.searchTopSongs(from: rawText, artistMatches: matches)
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 1.2)) {
                    self.progressStep = 3
                }
                
                self.playlistEntries = songs
                for entry in songs {
                    print("🎵 \(entry.artistName) - \(entry.trackTitle)")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.navigateToMadePlaylist = true
                    }
                }
            }
        }
    }
    
    /// Apple Music으로 플레이리스트를 내보내는 트리거 함수
    func exportToAppleMusic() {
        isExporting = true

        Task {
            await exportViewModelWrapper.exportLatestPlaylistToAppleMusic()

            // 내보내기 완료 후 상태 업데이트 (5초 후 완료 상태 전환)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.isExporting = false
                self.isExportCompleted = true
            }
        }
    }
    
    /// 플레이리스트에서 특정 곡 삭제
    func deleteEntry(at indexSet: IndexSet) {
        playlistEntries.remove(atOffsets: indexSet)
        
        // 삭제된 곡이 현재 재생 중이었다면 재생 중지
        if let playingTrackId = currentlyPlayingTrackId {
            let remainingTrackIds = playlistEntries.map { $0.trackId }
            if !remainingTrackIds.contains(playingTrackId) {
                Task {
                    await musicPlayerUseCase.musicRepository.stopPreview()
                }
            }
        }
    }
    
    /// 30초 미리듣기 재생/일시정지 토글
    func togglePreview(for trackId: String) {
        Task {
            await musicPlayerUseCase.musicRepository.togglePreview(for: trackId)
        }
    }
}
