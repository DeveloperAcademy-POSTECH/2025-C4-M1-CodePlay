//
//  AppleMusicConnectView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

internal import Combine
import MusicKit
import SwiftData
import SwiftUI

struct AppleMusicConnectView: View {
    @EnvironmentObject var viewModelWrapper: MusicViewModelWrapper
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단 여백 (Safe Area 고려하여 조정)
            Spacer().frame(height: 146)

            if viewModelWrapper.authorizationStatus?.status == .denied {
                Image(asset: Asset.linkfail)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            } else {
                Image(asset: Asset.linkapplemusic)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
            }

            // 사각형과 제목 사이 간격
            Spacer().frame(height: 76)

            VStack(spacing: 12) {
                Text("Apple Music을 연결해주세요")
                    .font(.HlgBold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.neu900)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineSpacing(2)

                Text("페스티벌 플레이리스트 생성을 위해\nApple Music을 연결해주세요.")
                    .font(.BmdRegular())
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.neu700)
                    .padding(.horizontal, 32)
                    .lineSpacing(2)
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
                        viewModelWrapper.appleMusicConnectViewModel
                            .shouldOpenSettings.value = true
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
                            viewModelWrapper.appleMusicConnectViewModel
                                .shouldRequestMusicAuthorization.value = true
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
        }
        .padding(.bottom, 37)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundWithBlur()
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
    @Published var selectedPlaylist: Playlist? = nil
    var shouldShowNoResultView: Bool = false
    @Published var showErrorView: Bool = false
    @Published var entrySource: PlaylistEntrySource = .main

    @Environment(\.modelContext) private var modelContext

    // MARK: - Dependencies
    var appleMusicConnectViewModel: any AppleMusicConnectViewModel
    var exportViewModelWrapper: any ExportPlaylistViewModel
    var festivalCheckViewModel: any FestivalCheckViewModel

    // MARK: - Init
    init(
        appleMusicConnectViewModel: any AppleMusicConnectViewModel,
        exportViewModelWrapper: any ExportPlaylistViewModel,
        festivalCheckViewModel: any FestivalCheckViewModel
    ) {
        self.appleMusicConnectViewModel = appleMusicConnectViewModel
        self.exportViewModelWrapper = exportViewModelWrapper
        self.festivalCheckViewModel = festivalCheckViewModel

        bind()
    }

    // MARK: - Binding Observables
    private func bind() {
        festivalCheckViewModel.isLoading.observe(on: self) {
            [weak self] value in
            DispatchQueue.main.async {
                self?.isLoading = value
            }
        }

        festivalCheckViewModel.festivalData.observe(on: self) {
            [weak self] value in
            DispatchQueue.main.async {
                self?.festivalData = value
            }
        }

        festivalCheckViewModel.suggestTitles.observe(on: self) {
            [weak self] value in
            DispatchQueue.main.async {
                self?.suggestTitles = value
            }
        }

        appleMusicConnectViewModel.authorizationStatus.observe(on: self) {
            [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                self?.canPlayMusic = (status?.status == .authorized)
            }
        }

        appleMusicConnectViewModel.subscriptionStatus.observe(on: self) {
            [weak self] in
            self?.subscriptionStatus = $0
        }

        appleMusicConnectViewModel.errorMessage.observe(on: self) {
            [weak self] in
            self?.errorMessage = $0
        }

        appleMusicConnectViewModel.canPlayMusic.observe(on: self) {
            [weak self] newValue in
            guard let self else { return }
            if self.canPlayMusic != newValue {
                DispatchQueue.main.async {
                    self.canPlayMusic = newValue
                }
            }
        }

        exportViewModelWrapper.artistCandidates.observe(on: self) {
            [weak self] value in
            guard let self else { return }
            Task { @MainActor in
                self.artistCandidates = value
            }
        }

        exportViewModelWrapper.currentlyPlayingTrackId.observe(on: self) {
            [weak self] trackId in
            guard let self else { return }
            Task { @MainActor in
                self.currentlyPlayingTrackId = trackId
            }
        }

        exportViewModelWrapper.isPlaying.observe(on: self) {
            [weak self] isPlaying in
            guard let self else { return }
            Task { @MainActor in
                self.isPlaying = isPlaying
            }
        }

        exportViewModelWrapper.playbackProgress.observe(on: self) {
            [weak self] progress in
            DispatchQueue.main.async {
                self?.playbackProgress = progress
            }
        }
    }

    // MARK: - Main Flow
    func onAppear(
        with rawText: RawText?,
        for playlist: Playlist,
        using context: ModelContext
    ) async {
        guard let rawText else { return }
        Log.debug("🟠 [onAppear] rawText: \(rawText.text)")

        await MainActor.run {
            self.progressStep = 0
        }

        exportViewModelWrapper.preProcessRawText(rawText)

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.progressStep = 1
            }
        }

        let matches = await exportViewModelWrapper.searchArtists(from: rawText)
        Log.debug("🔍 [searchArtists] 매칭된 아티스트 수: \(matches.count)")
        matches.forEach { Log.debug("🎤 \($0.artistName) (\($0.appleMusicId))") }

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.progressStep = 2
            }
        }

        let songs = await exportViewModelWrapper.searchTopSongs(
            from: rawText,
            artistMatches: matches
        )
        Log.debug("🎶 [searchTopSongs] 가져온 곡 수: \(songs.count)")
        songs.forEach { Log.debug("🎵 \( $0.artistName ) - \( $0.trackTitle )") }

        await MainActor.run {
            withAnimation(.easeInOut(duration: 1.2)) {
                self.progressStep = 3
            }
            self.playlistEntries = songs
            Log.debug("📦 [playlistEntries 저장 완료] \(songs.count)곡")
        }

        await savePlaylistAfterTopSongs(playlist: playlist, context: context)

        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.navigateToMadePlaylist = true
            }
        }
    }

    // MARK: - Save to SwiftData
    func savePlaylistAfterTopSongs(playlist: Playlist, context: ModelContext)
        async
    {
        guard !playlistEntries.isEmpty else {
            Log.debug("❌ 저장 시도했지만 playlistEntries가 비어 있음")
            return
        }

        let playlistId = playlist.id

        for entry in playlistEntries {
            guard !entry.trackId.isEmpty else {
                Log.debug("⚠️ 잘못된 Entry - trackId 없음: \(entry.artistName)")
                continue
            }
            entry.playlistId = playlistId
            context.insert(entry)
            Log.debug(
                "📦 저장할 Entry: \(entry.artistName) - \(entry.trackTitle) / \(entry.trackId)"
            )
        }

        do {
            try context.save()
            Log.debug("✅ 기존 Playlist에 Entry 추가 완료")
        } catch {
            Log.fault("❌ 저장 실패: \(error)")
        }
    }

    // MARK: - Export
    /// Apple Music으로 플레이리스트를 내보내는 트리거 함수
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

    func exportSelectedPlaylistToAppleMusic(entries: [PlaylistEntry]) {
        // 기존 playlistEntries를 임시로 백업
        let originalEntries = self.playlistEntries

        // 선택된 엔트리들로 교체
        self.playlistEntries = entries

        // 기존 exportToAppleMusic 메서드 호출
        self.exportToAppleMusic()

        // 원래 엔트리들로 복원 (필요한 경우)
        // self.playlistEntries = originalEntries
    }

    /// 플레이리스트에서 특정 곡 삭제
    func deletePlaylistEntry(trackId: String) {
        Task {
            // 현재 재생 중인 곡이라면 먼저 음악 정지
            if currentlyPlayingTrackId == trackId {
                await exportViewModelWrapper.stopPreview()
            }
            await exportViewModelWrapper.deletePlaylistEntry(trackId: trackId)
            await MainActor.run {
                if currentlyPlayingTrackId == trackId {
                    currentlyPlayingTrackId = nil
                    isPlaying = false
                    playbackProgress = 0.0
                }
                playlistEntries.removeAll { $0.trackId == trackId }
            }
        }
    }
    func deleteEntry(at indexSet: IndexSet) {
        for index in indexSet {
            let trackId = playlistEntries[index].trackId
            deletePlaylistEntry(trackId: trackId)
        }
    }

    func togglePreview(for trackId: String) {
        Task {
            await exportViewModelWrapper.togglePreview(for: trackId)
        }
    }
}
