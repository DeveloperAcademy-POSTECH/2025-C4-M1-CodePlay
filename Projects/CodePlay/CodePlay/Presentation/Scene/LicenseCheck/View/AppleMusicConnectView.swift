    //
    //  AppleMusicConnectView.swift
    //  CodePlay
    //
    //  Created by 성현 on 7/15/25.
    //

    internal import Combine
    import MusicKit
    import SwiftUI
    import SwiftData

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
        // MARK: - Published Properties
        @Published var authorizationStatus: MusicAuthorizationStatusModel?
        @Published var subscriptionStatus: MusicSubscriptionModel?
        @Published var errorMessage: String?
        @Published var canPlayMusic: Bool = false
        @Published var artistCandidates: [String] = []
        @Published var progressStep: Int = 0
        @Published var navigateToMadePlaylist: Bool = false
        @Published var isExporting: Bool = false
        @Published var isExportCompleted: Bool = false
        @Published var playlistEntries: [PlaylistEntry] = []
        @Published var currentlyPlayingTrackId: String?
        @Published var isPlaying: Bool = false
        @Published var playbackProgress: Double = 0.0
        @Published var isLoading: Bool = true
        @Published var festivalData: DynamoDataItem? = nil
        @Published var suggestTitles: [String] = []

        @Environment(\.modelContext) private var modelContext

        // MARK: - Dependencies
        var appleMusicConnectViewModel: any AppleMusicConnectViewModel
        var exportViewModelWrapper: any ExportPlaylistViewModel
        var festivalCheckViewModel: any FestivalCheckViewModel
        private var musicPlayerUseCase: MusicPlayerUseCase

        // MARK: - Init
        init(
            appleMusicConnectViewModel: any AppleMusicConnectViewModel,
            exportViewModelWrapper: any ExportPlaylistViewModel,
            festivalCheckViewModel: any FestivalCheckViewModel,
            musicPlayerUseCase: MusicPlayerUseCase
        ) {
            self.appleMusicConnectViewModel = appleMusicConnectViewModel
            self.exportViewModelWrapper = exportViewModelWrapper
            self.festivalCheckViewModel = festivalCheckViewModel
            self.musicPlayerUseCase = musicPlayerUseCase

            bind()
        }

        // MARK: - Binding Observables
        private func bind() {
            festivalCheckViewModel.isLoading.observe(on: self) { [weak self] in self?.isLoading = $0 }
            festivalCheckViewModel.festivalData.observe(on: self) { [weak self] in self?.festivalData = $0 }
            festivalCheckViewModel.suggestTitles.observe(on: self) { [weak self] in self?.suggestTitles = $0 }

            appleMusicConnectViewModel.authorizationStatus.observe(on: self) { [weak self] status in
                DispatchQueue.main.async {
                    self?.authorizationStatus = status
                    self?.canPlayMusic = (status?.status == .authorized)
                }
            }

            appleMusicConnectViewModel.subscriptionStatus.observe(on: self) { [weak self] in self?.subscriptionStatus = $0 }
            appleMusicConnectViewModel.errorMessage.observe(on: self) { [weak self] in self?.errorMessage = $0 }
            appleMusicConnectViewModel.canPlayMusic.observe(on: self) { [weak self] newValue in
                guard let self = self else { return }
                if self.canPlayMusic != newValue {
                    DispatchQueue.main.async {
                        self.canPlayMusic = newValue
                    }
                }
            }


            exportViewModelWrapper.artistCandidates.observe(on: self) { [weak self] in self?.artistCandidates = $0 }

            musicPlayerUseCase.setupRepositoryCallbacks(
                onPlaybackStateChanged: { [weak self] trackId, isPlaying in
                    self?.currentlyPlayingTrackId = trackId
                    self?.isPlaying = isPlaying
                },
                onProgressChanged: { [weak self] progress in
                    print("🎯 [MusicViewModelWrapper] 진행률: \(progress)")
                    self?.playbackProgress = progress
                }
            )
        }

        // MARK: - Main Flow (Refactored)
        func onAppear(with rawText: RawText?, for playlist: Playlist, using context: ModelContext) async {
            guard let rawText else { return }
            print("🟠 [onAppear] rawText: \(rawText.text)")

            progressStep = 0
            exportViewModelWrapper.preProcessRawText(rawText)
            withAnimation(.easeInOut(duration: 0.5)) { progressStep = 1 }

            let matches = await exportViewModelWrapper.searchArtists(from: rawText)
            print("🔍 [searchArtists] 매칭된 아티스트 수: \(matches.count)")
            matches.forEach { print("🎤 \($0.artistName) (\($0.appleMusicId))") }

            withAnimation(.easeInOut(duration: 0.5)) { progressStep = 2 }

            let songs = await exportViewModelWrapper.searchTopSongs(from: rawText, artistMatches: matches)
            print("🎶 [searchTopSongs] 가져온 곡 수: \(songs.count)")
            songs.forEach { print("🎵 \( $0.artistName ) - \( $0.trackTitle )") }

            withAnimation(.easeInOut(duration: 1.2)) { progressStep = 3 }

            playlistEntries = songs
            print("📦 [playlistEntries 저장 완료] \(playlistEntries.count)곡")

            await savePlaylistAfterTopSongs(playlist: playlist, context: context)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.navigateToMadePlaylist = true
                }
            }
        }


        // MARK: - Save to SwiftData
        func savePlaylistAfterTopSongs(playlist: Playlist, context: ModelContext) async {
            guard !playlistEntries.isEmpty else {
                print("❌ 저장 시도했지만 playlistEntries가 비어 있음")
                return
            }

            let playlistId = playlist.id

            for entry in playlistEntries {
                guard !entry.trackId.isEmpty else {
                    print("⚠️ 잘못된 Entry - trackId 없음: \(entry.artistName)")
                    continue
                }
                entry.playlistId = playlistId
                context.insert(entry)

                print("📦 저장할 Entry: \(entry.artistName) - \(entry.trackTitle) / \(entry.trackId)")
            }

            do {
                try context.save()
                print("✅ 기존 Playlist에 Entry 추가 완료")
            } catch {
                print("❌ 저장 실패: \(error)")
            }
        }


        // MARK: - Export
        func exportToAppleMusic() {
            isExporting = true
            Task {
                await exportViewModelWrapper.exportLatestPlaylistToAppleMusic()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isExporting = false
                    self.isExportCompleted = true
                }
            }
        }

        // MARK: - Playback Controls
        func deleteEntry(at indexSet: IndexSet) {
            playlistEntries.remove(atOffsets: indexSet)
            if let playingTrackId = currentlyPlayingTrackId,
               !playlistEntries.map({ $0.trackId }).contains(playingTrackId) {
                Task { await musicPlayerUseCase.musicRepository.stopPreview() }
            }
        }

        func togglePreview(for trackId: String) {
            Task { await musicPlayerUseCase.musicRepository.togglePreview(for: trackId) }
        }
    }
