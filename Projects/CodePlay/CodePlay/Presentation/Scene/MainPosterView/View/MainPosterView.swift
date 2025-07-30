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
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                    Spacer().frame(height: 146)
            
                    if playlists.isEmpty {
                        VStack(alignment: .center, spacing: 76) {
                            Image("Mainempty")
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: 320)
                        }
                        .padding(.horizontal, 36)

                    } else {
                        VStack {
                            OverlappingCardsView(playlists: playlists, wrapper: musicWrapper) //임시입다
                            .padding(.bottom, 12)
                        }
                    }
                    
                    Spacer().frame(height: 36)
                    
                    Text("페스티벌에 가기 전\n슝으로 예습해 보세요!")
                        .multilineTextAlignment(.center)
                        .font(.HlgBold())
                        .foregroundColor(.neu900)
                        .padding(.horizontal, 36)
                        .lineSpacing(2)

                    Spacer().frame(height: 12)
                    
                    Text("포스터 인식으로 플레이리스트를 만들 수 있어요")
                        .font(.BmdRegular())
                        .foregroundColor(.neu700)
                        .padding(.horizontal, 36)
                        .lineSpacing(2)
                                        
                    Spacer()
                    
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
                            FestivalView(rawText: wrapper.scannedText)
                                .environmentObject(musicWrapper)
                        }
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
            .edgesIgnoringSafeArea(.all)
            .backgroundWithBlur()
            .navigationBarHidden(true)
            .onAppear {
                print("🧾 현재 Playlist 수: \(playlists.count)")
                for p in playlists {
                    print("📀 \(p.title) / \(p.createdAt)")
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
        }
    }
    
}

// MARK: PosterViewModelWrapper
final class PosterViewModelWrapper: ObservableObject {
    @Published var shouldNavigateToFestivalCheck: Bool = false
    @Published var shouldNavigateToMakePlaylist: Bool = false
    @Published var scannedText: RawText? = nil
    var viewModel: any PosterViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: any PosterViewModel) {
        self.viewModel = viewModel

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
