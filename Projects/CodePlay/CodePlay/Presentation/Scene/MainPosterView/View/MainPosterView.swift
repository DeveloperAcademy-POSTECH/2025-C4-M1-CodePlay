//
//  MainPosterView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
internal import Combine
import SwiftData

struct MainPosterView: View {
    @EnvironmentObject var wrapper: PosterViewModelWrapper
    @State private var recognizedText: String = ""
    @State private var isNavigateToScanPoster = false
    @Environment(\.modelContext) var modelContext
    let diContainer: MainSceneDIContainer
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
                
                ArtistCard(imageUrl: wrapper.festivalInfo.imageURL?.absoluteString, date: wrapper.festivalInfo.date, title: wrapper.festivalInfo.title, subTitle: wrapper.festivalInfo.subtitle)
                Spacer().frame(height: 36)
                
                Text("페스티벌 포스터로 미리 예습해보세요!")
                
                Spacer().frame(height: 12)
                
                Text("인식해 애플뮤직 플레이리스트로 만들어보세요")
                
                Spacer()
                
                BottomButton(title: "페스티벌 라인업 인식", action: {
                    recognizedText = ""
                    isNavigateToScanPoster = true
                })
                .padding(.bottom, 36)
                
                NavigationLink(
                    destination: ExportPlaylistView(
                       rawText: wrapper.scannedText,
                       wrapper: diContainer.makeExportPlaylistViewModelWrapper(modelContext: modelContext)),
                    isActive: $wrapper.shouldNavigateToMakePlaylist
                ) {
                    EmptyView()
                }
            }
            .fullScreenCover(isPresented: $isNavigateToScanPoster) {
                ScanPosterView(recognizedText: $recognizedText)
                    .environmentObject(wrapper)
            }
        }
    }
}

// MARK: PosterViewModelWrapper
final class PosterViewModelWrapper: ObservableObject {
    @Published var festivalInfo: PosterItemModel = .mock
    @Published var shouldNavigateToMakePlaylist: Bool = false
    @Published var scannedText: RawText? = nil
    var viewModel: any PosterViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any PosterViewModel) {
        self.viewModel = viewModel
        
        // Observable을 통해 festivalInfo 변화를 감지하고 업데이트 함
        viewModel.festivalData.observe(on: self) { [weak self] items in
            guard let item = items.first else {return}
            self?.festivalInfo = item
        }
        
        viewModel.shouldNavigateToMakePlaylist.observe(on: self) { [weak self] newData in
            self?.shouldNavigateToMakePlaylist = newData
        }
    
        viewModel.scannedText.observe(on: self) { [weak self] newData in
            self?.scannedText = newData
        }
    }
}
