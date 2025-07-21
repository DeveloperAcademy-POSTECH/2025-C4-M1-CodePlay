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
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    let rawText: RawText?

    init(rawText: RawText?) {
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
                destination: MadePlaylistView(), // 생성 완료 후 이동
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
