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
        VStack {
            Text("🎵 후보 아티스트")
                .font(.title)
            ForEach(wrapper.artistCandidates, id: \.self) { artist in
                Text(artist)
            }
        }
        .onAppear {
            wrapper.onAppear(with: rawText)
        }
    }
}

final class ExportPlaylistViewModelWrapper: ObservableObject {
    @Published var artistCandidates: [String] = []

    let viewModel: ExportPlaylistViewModel

    init(viewModel: ExportPlaylistViewModel) {
        self.viewModel = viewModel

        // 옵저버 연결
        viewModel.artistCandidates.observe(on: self) { [weak self] candidates in
            self?.artistCandidates = candidates
        }
    }

    func onAppear(with rawText: RawText?) {
        guard let rawText = rawText else { return }
        viewModel.preProcessRawText(rawText)
    }
}

