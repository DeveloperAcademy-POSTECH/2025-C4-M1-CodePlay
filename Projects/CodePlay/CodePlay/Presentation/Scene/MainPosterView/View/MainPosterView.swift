//
//  MainPosterView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine

struct MainPosterView: View {
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
                    .environmentObject(wrapper),
//                        .onChange(of: recognizedText) {
//                            wrapper.viewModel.updateRecognizedText(recognizedText)
//                            isNavigateToScanPoster = false
//                        },
                    isActive: $isNavigateToScanPoster
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: ExportPlaylistView(rawText: wrapper.viewModel.scannedText),
                    isActive: $wrapper.viewModel.shouldNavigateToMakePlaylist
                ) {
                    EmptyView()
                }
            }
        }
    }
}

final class FetchFestivalViewModelWrapper: ObservableObject {
    @Published var festivalInfo: PosterItemModel
    
    var viewModel: any PosterViewModel

    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: some PosterViewModel) {
        self.viewModel = viewModel
        self.festivalInfo = .empty
        // Observable을 통해 festivalInfo 변화를 감지하고 업데이트 함
        viewModel.festivalData.observe(on: self) { [weak self] items in
            guard let item = items.first else {return}
            self?.festivalInfo = item
        }
    }
}
