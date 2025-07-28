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
    @Query(sort: \Playlist.createdAt, order: .reverse) private var playlists: [Playlist]
    
    var body: some View {
//        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                Color.clear
                    .backgroundWithBlur()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)
            
                    if playlists.isEmpty {
                        VStack(alignment: .center) {
                            Image("Mainempty")
                                .resizable()
                                .scaledToFit()
                            Text("아직 인식한 페스티벌\n라인업이 없습니다")
                                .multilineTextAlignment(.center)
                                .font(.BlgRegular())
                                .foregroundColor(.neu900)
                        }
                        .frame(maxHeight: 420)
                        .padding(.horizontal, 72)
                        .liquidGlass(style: .card)

                    } else {
                        VStack {
                            OverlappingCardsView(playlists: playlists)
                            .padding(.bottom, 12)
                        }
                    }
                    
                    Spacer().frame(height: 25)
                    
                    Text("페스티벌에 가기 전\n노래를 미리 예습해 보세요!")
                        .multilineTextAlignment(.center)
                        .font(.HlgBold())
                        .foregroundColor(.neu900)
                    
                    Spacer().frame(height: 12)
                    
                    Text("포스터 인식으로 플레이리스트를 만들 수 있어요")
                        .font(.BmdRegular())
                        .foregroundColor(.neu700)
                    
                    Spacer().frame(height: 35)
                    
                    BottomButton(title: "페스티벌 라인업 인식", kind: .colorFill, action: {
                        recognizedText = ""
                        isNavigateToScanPoster = true
                    })
                    .padding(.bottom, 16)
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 25)
                    
                    NavigationLink(
                        isActive: $wrapper.shouldNavigateToFestivalCheck,
                        destination: {
                            FestivalCheckView(rawText: wrapper.scannedText)
                                .environmentObject(musicWrapper)
                        }
                    ) {
                        EmptyView()
                    }
                }
            }

            .fullScreenCover(isPresented: $isNavigateToScanPoster) {
                CameraLiveTextView(
                    recognizedText: $recognizedText,
                    isPresented: $isNavigateToScanPoster
                )
                .ignoresSafeArea()
                .environmentObject(wrapper)
            }
            .ignoresSafeArea()
//        }
    }
}

// MARK: PosterViewModelWrapper
final class PosterViewModelWrapper: ObservableObject {
    @Published var shouldNavigateToFestivalCheck: Bool = false
    @Published var shouldNavigateToMakePlaylist: Bool = false
    @Published var scannedText: RawText? = nil
    var viewModel: any PosterViewModel
    var playlist: Playlist
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any PosterViewModel, playlist: Playlist) {
        self.viewModel = viewModel
        self.playlist = playlist
        
        viewModel.shouldNavigateToFestivalCheck.observe(on: self) { [weak self] newData in
            self?.shouldNavigateToFestivalCheck = newData
        }
        
        viewModel.shouldNavigateToMakePlaylist.observe(on: self) { [weak self] newData in
            self?.shouldNavigateToMakePlaylist = newData
        }
    
        viewModel.scannedText.observe(on: self) { [weak self] newData in
            self?.scannedText = newData
        }
    }
}
