//
//  ExportPlaylistView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine

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

struct MadePlaylistView: View {
    @ObservedObject var wrapper: ExportPlaylistViewModelWrapper

    var body: some View {
        VStack(spacing: 32) {
            BottomButton(title: "Apple Music으로 전송") {
                wrapper.exportToAppleMusic()
            }
            .padding(.horizontal, 16)

            Spacer()
        }
        .background(
            NavigationLink(destination: ExportLoadingView(wrapper: wrapper), isActive: $wrapper.isExporting) {
                EmptyView()
            }
        )
        .fullScreenCover(isPresented: $wrapper.isExportCompleted) {
            ExportSuccessView()
        }
    }
}

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


final class ExportPlaylistViewModelWrapper: ObservableObject {
    @Published var artistCandidates: [String] = []
    @Published var progressStep: Int = 0
    @Published var navigateToMadePlaylist: Bool = false
    @Published var isExporting: Bool = false
    @Published var isExportCompleted: Bool = false

    let viewModel: ExportPlaylistViewModel

    init(viewModel: ExportPlaylistViewModel) {
        self.viewModel = viewModel
        viewModel.artistCandidates.observe(on: self) { [weak self] candidates in
            self?.artistCandidates = candidates
        }
    }

    func onAppear(with rawText: RawText?) {
        guard let rawText else { return }

        progressStep = 0

        viewModel.preProcessRawText(rawText)
        progressStep = 1

        Task {
            let matches = await viewModel.searchArtists(from: rawText)
            DispatchQueue.main.async {
                self.progressStep = 2
                matches.forEach { print("✅ \( $0.artistName ) (\($0.appleMusicId))") }
            }

            let songs = await viewModel.searchTopSongs(from: rawText, artistMatches: matches)
            DispatchQueue.main.async {
                self.progressStep = 3
                for entry in songs {
                    print("🎵 \(entry.artistName) - \(entry.trackTitle)")
                }
                self.navigateToMadePlaylist = true
            }
        }
    }
    
    func exportToAppleMusic() {
            isExporting = true

            Task {
                await viewModel.exportLatestPlaylistToAppleMusic()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isExporting = false
                    self.isExportCompleted = true
                }
            }
        }
}
