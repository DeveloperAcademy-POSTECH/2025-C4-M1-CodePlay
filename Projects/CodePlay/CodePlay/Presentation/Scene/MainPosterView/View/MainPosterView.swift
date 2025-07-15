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
            VStack(spacing: 0) {
                ArtistCard(imageUrl: wrapper.festivalInfo.imageURL?.absoluteString, date: wrapper.festivalInfo.date, title: wrapper.festivalInfo.title, subTitle: wrapper.festivalInfo.subtitle)
                Spacer().frame(height: 36)
                
                Text("페스티벌 포스터로 미리 예습해보세요!")
                
                Spacer().frame(height: 12)
                
                Text("인식해 애플뮤직 플레이리스트로 만들어보세요")
                
//                Spacer().frame(height: 56)
                Spacer()

                BottomButton(title: "페스티벌 라인업 인식", action: {
                    recognizedText = ""
                    isNavigateToScanPoster = true
                })
                .padding(.bottom, 36)
               
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
    @Published var festivalInfo: PosterItemModel = .mock
    
    var viewModel: any PosterViewModel

    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: some PosterViewModel) {
        self.viewModel = viewModel
        // Observable을 통해 festivalInfo 변화를 감지하고 업데이트 함
        viewModel.festivalData.observe(on: self) { [weak self] items in
            guard let item = items.first else {return}
            self?.festivalInfo = item
        }
    }
}
