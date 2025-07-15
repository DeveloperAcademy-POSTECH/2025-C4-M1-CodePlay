//
//  FetchFestivalView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine

struct FetchFestivalView: View {
    @EnvironmentObject var wrapper: FetchFestivalViewModelWrapper
    @State private var recognizedText: String = ""
    @State private var isNavigateToScanPoster = false

    var body: some View {
        NavigationStack {
            VStack {
                Button("포스터 스캔 시작") {
                    recognizedText = ""
                    isNavigateToScanPoster = true
                }

                NavigationLink(destination:
                    ScanPosterView(recognizedText: $recognizedText)
                        .onChange(of: recognizedText) { newValue in
                            wrapper.scanPosterViewModel.updateRecognizedText(newValue)
                            isNavigateToScanPoster = false
                        },
                    isActive: $isNavigateToScanPoster
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: MakePlaylistView(rawText: wrapper.scannedText),
                    isActive: $wrapper.shouldNavigateToMakePlaylist
                ) {
                    EmptyView()
                }
            }
        }
    }
}

final class FetchFestivalViewModelWrapper: ObservableObject {
    let viewModel: any FetchFestivalViewModel
    let scanPosterViewModel: ScanPosterViewModel

    @Published var scannedText: RawText?
    @Published var shouldNavigateToMakePlaylist: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(
        viewModel: some FetchFestivalViewModel,
        scanPosterViewModel: ScanPosterViewModel
    ) {
        self.viewModel = viewModel
        self.scanPosterViewModel = scanPosterViewModel
        observeScanResult()
    }

    private func observeScanResult() {
        scanPosterViewModel.$scannedText
            .compactMap { $0 }
            .sink { [weak self] text in
                self?.scannedText = text
                self?.shouldNavigateToMakePlaylist = true
            }
            .store(in: &cancellables)
    }
}
