//
//  ExportSuccessView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/21/25.
//

import SwiftUI

// MARK: 전송 완료 이후, 애플뮤직 앱으로 전환하는 뷰
struct ExportSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var posterWrapper: PosterViewModelWrapper
    @EnvironmentObject var musicWrapper: MusicViewModelWrapper
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @State private var isNavigateToMainPoster = false

    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.clear
                    .backgroundWithBlur()
                    .ignoresSafeArea()
                VStack(spacing: 0) {
                    Image("Playlist")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320, height: 320)
                        .padding(.top, 80)
                        .padding(.bottom, 96)
                    
                    VStack(spacing: 12) {
                        Text("Apple Music에\n플레이리스트를 생성했어요!")
                            .font(.HlgBold())
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.neu900)
                        
                        Text("애플뮤직에서 생성된 플레이리스트를 확인해보세요.")
                            .font(.BmdRegular())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.neu700)
                    }
                    .padding(.bottom, 80)
                    
                    BottomButton(title: "Apple Music으로 가기", kind: .line) {
                        if let url = URL(string: "music://") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                NavigationLink(
                    destination: MainPosterView()
                        .environmentObject(posterWrapper)
                        .environmentObject(musicWrapper),
                    isActive: $isNavigateToMainPoster
                ) {
                    EmptyView()
                }
                .hidden()

            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        posterWrapper.shouldNavigateToMakePlaylist = false
                        posterWrapper.viewModel.clearText()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isNavigateToMainPoster = true
                        }
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.neu900)
                            .font(.system(size: 16, weight: .medium))
                    })
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

