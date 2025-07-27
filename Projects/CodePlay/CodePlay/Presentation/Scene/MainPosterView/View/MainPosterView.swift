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
    @State private var isNavigateToExmapleView = false // 예시뷰
    @Environment(\.modelContext) var modelContext
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.clear
                    .backgroundWithBlur()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)
            
                    if wrapper.festivalInfo.isEmpty {
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
                            OverlappingCardsView(festivals: wrapper.festivalInfo)
                            
                            Spacer().frame(height: 12)
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
                        isActive: $wrapper.shouldNavigateToMakePlaylist,
                        destination: {
                            ExportPlaylistView(rawText: wrapper.scannedText)
                                .environmentObject(musicWrapper)
                        }
                    ) {
                        EmptyView()
                    }
                }
                
                // TODO: UI확인을 위해 임시로 첫번째 공연 포스터를 들고오도록 설정 -> 추후 수정
                NavigationLink(
                    destination: FestivalCheckView(festival: wrapper.festivalInfo.first!),
                    isActive: $isNavigateToExmapleView
                ) {
                    EmptyView()
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
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        isNavigateToExmapleView = true
                    }, label: {
                        Text("버튼")
                            .foregroundColor(Color("Primary"))
                            
                    })
                    .background(.clear)
                }
            }
            .ignoresSafeArea()
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




