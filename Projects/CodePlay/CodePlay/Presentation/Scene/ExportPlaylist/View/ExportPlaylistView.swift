//
//  ExportPlaylistView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine
import MusicKit

// MARK: 애플뮤직 플레이리스트로 전송하는 뷰 (hifi 05_1부분)
struct ExportPlaylistView: View {
    @StateObject private var wrapper: ExportPlaylistViewModelWrapper
    let rawText: RawText?

    init(rawText: RawText?, wrapper: ExportPlaylistViewModelWrapper) {
        _wrapper = StateObject(wrappedValue: wrapper)
        self.rawText = rawText
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("🎵 플레이리스트 생성 중...")
                .font(.title2)

            ProgressView(value: Double(wrapper.progressStep), total: 3)
                .progressViewStyle(LinearProgressViewStyle())
                .padding(.horizontal)

            Text(progressMessage(for: wrapper.progressStep))
                .font(.subheadline)

            Spacer()

            NavigationLink(
                destination: MadePlaylistView(wrapper: wrapper), // 생성 완료 후 이동
                isActive: $wrapper.navigateToMadePlaylist
            ) {
                EmptyView()
            }
        }
        .onAppear {
            wrapper.onAppear(with: rawText)
        }
    }

    private func progressMessage(for step: Int) -> String {
        switch step {
        case 0: return "🎬 준비 중..."
        case 1: return "🔍 아티스트 검색 중..."
        case 2: return "🎶 인기곡 가져오는 중..."
        case 3: return "✅ 완료!"
        default: return ""
        }
    }
}

// MARK: 애플뮤직 플레이리스트로 전송하는 뷰 (hifi 06_1부분)
struct ExportLoadingView: View {
    @ObservedObject var wrapper: ExportPlaylistViewModelWrapper
    @State private var progress: Double = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Apple Music으로 전송 중...")
                .font(.title3)

            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 5)) {
                progress = 1.0
            }
        }
    }
}

// MARK: 전송 완료 이후, 애플뮤직 앱으로 전환하는 뷰 (hifi 07_1부분)
struct ExportSuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text("🎉 전송이 완료되었습니다!")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                BottomButton(title: "Apple Music으로 이동") {
                    if let url = URL(string: "music://") {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("전송 완료")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}


/// ExportPlaylist 흐름에서 사용하는 ViewModel 래퍼
/// - 내부 ViewModel의 상태를 SwiftUI에서 구독 가능하도록 래핑
final class ExportPlaylistViewModelWrapper: ObservableObject {
    /// 후보 아티스트 문자열 리스트 (OCR → 후보 추출 결과)
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

    /// 내부 실제 비즈니스 로직을 담당하는 ViewModel
    let viewModel: ExportPlaylistViewModel
    
    /// MusicKit 플레이어 (30초 미리듣기용)
    private let player = ApplicationMusicPlayer.shared

    /// 생성자: 내부 ViewModel을 주입받아, 상태 변화를 observe로 바인딩
    init(viewModel: ExportPlaylistViewModel) {
        self.viewModel = viewModel

        // 내부 viewModel에서 발행하는 artistCandidates를 이 래퍼에 반영
        viewModel.artistCandidates.observe(on: self) { [weak self] candidates in
            self?.artistCandidates = candidates
        }
    }

    /// View가 나타날 때 호출되는 함수
    /// - OCR로부터 받은 RawText를 바탕으로 전체 흐름 수행
    func onAppear(with rawText: RawText?) {
        guard let rawText else { return }

        progressStep = 0

        // 1단계: 텍스트 전처리 (후보 아티스트 추출)
        viewModel.preProcessRawText(rawText)
        progressStep = 1

        Task {
            // 2단계: 아티스트 검색
            let matches = await viewModel.searchArtists(from: rawText)
            DispatchQueue.main.async {
                self.progressStep = 2
                matches.forEach { print("✅ \( $0.artistName ) (\($0.appleMusicId))") }
            }

            // 3단계: 아티스트별 상위 곡 검색
            let songs = await viewModel.searchTopSongs(from: rawText, artistMatches: matches)
            DispatchQueue.main.async {
                self.progressStep = 3
                self.playlistEntries = songs
                for entry in songs {
                    print("🎵 \(entry.artistName) - \(entry.trackTitle)")
                }
                self.navigateToMadePlaylist = true
            }
        }
    }
    
    /// Apple Music으로 플레이리스트를 내보내는 트리거 함수
    func exportToAppleMusic() {
        isExporting = true

        Task {
            await viewModel.exportLatestPlaylistToAppleMusic()

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
                    await stopPreview()
                }
            }
        }
    }
    
    /// 30초 미리듣기 재생/일시정지 토글
    func togglePreview(for trackId: String) {
        print("🎯 앨범 커버 탭됨 - trackId: \(trackId)")
        print("🎯 현재 재생 중인 곡: \(currentlyPlayingTrackId ?? "없음")")
        print("🎯 재생 상태: \(isPlaying)")
        
        if currentlyPlayingTrackId == trackId && isPlaying {
            // 같은 곡이 재생 중이면 일시정지
            print("🎯 일시정지 실행")
            pausePreview()
        } else {
            // 다른 곡이거나 재생 중이 아니면 재생 시작
            print("🎯 재생 시작 실행")
            playPreview(trackId: trackId)
        }
    }
    
    /// 미리듣기 재생 시작
    private func playPreview(trackId: String) {
        Task {
            do {
                // 이전 곡 중지
                await stopPreview()
                
                // Apple Music 권한 확인
                let authorizationStatus = await MusicAuthorization.request()
                guard authorizationStatus == .authorized else {
                    print("❌ Apple Music 권한이 필요합니다")
                    return
                }
                
                // MusicKit으로 곡 정보 가져오기
                let musicItemID = MusicItemID(trackId)
                let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
                let response = try await request.response()
                
                guard let song = response.items.first else {
                    print("❌ 곡을 찾을 수 없습니다: \(trackId)")
                    return
                }
                
                // 재생 시작
                player.queue = [song]
                try await player.play()
                
                await MainActor.run {
                    self.currentlyPlayingTrackId = trackId
                    self.isPlaying = true
                    print("🎵 재생 시작: \(song.title)")
                }
                
                // 30초 후 자동 정지
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    if self.currentlyPlayingTrackId == trackId {
                        Task {
                            await self.stopPreview()
                        }
                    }
                }
                
            } catch {
                print("❌ 재생 실패: \(error.localizedDescription)")
                await MainActor.run {
                    self.currentlyPlayingTrackId = nil
                    self.isPlaying = false
                }
            }
        }
    }
    
    /// 미리듣기 일시정지
    private func pausePreview() {
        Task {
            do {
                try await player.pause()
                await MainActor.run {
                    self.isPlaying = false
                    print("⏸️ 일시정지")
                }
            } catch {
                print("❌ 일시정지 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 미리듣기 중지
    private func stopPreview() async {
        do {
            try await player.stop()
            await MainActor.run {
                self.currentlyPlayingTrackId = nil
                self.isPlaying = false
                print("⏹️ 재생 중지")
            }
        } catch {
            print("❌ 중지 실패: \(error.localizedDescription)")
        }
    }
}
