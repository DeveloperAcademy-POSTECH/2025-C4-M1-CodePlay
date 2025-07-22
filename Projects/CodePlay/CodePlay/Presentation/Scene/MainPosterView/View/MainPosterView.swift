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
    @EnvironmentObject var musicWrapper: MusicViewModelWrapper
    @State private var recognizedText: String = ""
    @State private var isNavigateToScanPoster = false
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)
        
                if wrapper.festivalInfo.isEmpty {
                    VStack(alignment: .center) {
                        Text("아직 인식한 페스티벌 라인업이 없습니다.")
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: 420)
                    .padding(.horizontal, 72)
                    .liquidGlass()

                } else {
                    OverlappingCardsView(festivals: wrapper.festivalInfo)
                }
                
                Spacer().frame(height: 56)
                
                Text("페스티벌 포스터로 미리 예습해보세요!")
                
                Spacer().frame(height: 12)
                
                Text("인식해 애플뮤직 플레이리스트로 만들어보세요")
                
                Spacer()
                
                BottomButton(title: "페스티벌 라인업 인식", action: {
                    recognizedText = ""
                    isNavigateToScanPoster = true
                })
                .padding(.bottom, 16)
                
                NavigationLink(
                    isActive: $wrapper.shouldNavigateToMakePlaylist,
                    destination: {
                        ExportPlaylistView(rawText: wrapper.scannedText)
                            .environmentObject(musicWrapper)
                    }
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
    @Published var festivalInfo: [PosterItemModel] = PosterItemModel.mock
    @Published var shouldNavigateToMakePlaylist: Bool = false
    @Published var scannedText: RawText? = nil
    var viewModel: any PosterViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any PosterViewModel) {
        self.viewModel = viewModel
        
        // Observable을 통해 festivalInfo 변화를 감지하고 업데이트 함
        viewModel.festivalData.observe(on: self) { [weak self] items in
            if !items.isEmpty {
                self?.festivalInfo = items
            }
        }
        
        viewModel.shouldNavigateToMakePlaylist.observe(on: self) { [weak self] newData in
            self?.shouldNavigateToMakePlaylist = newData
        }
    
        viewModel.scannedText.observe(on: self) { [weak self] newData in
            self?.scannedText = newData
        }
    }
}
