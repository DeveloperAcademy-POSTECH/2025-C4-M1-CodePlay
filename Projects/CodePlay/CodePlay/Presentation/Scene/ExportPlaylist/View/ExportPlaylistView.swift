//
//  ExportPlaylistView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine

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

    /// 내부 실제 비즈니스 로직을 담당하는 ViewModel
    let viewModel: ExportPlaylistViewModel

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
}
