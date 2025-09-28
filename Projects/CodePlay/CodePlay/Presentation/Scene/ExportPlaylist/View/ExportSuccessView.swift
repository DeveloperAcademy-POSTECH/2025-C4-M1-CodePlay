//
//  ExportSuccessView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/21/25.
//

import SwiftUI

// MARK: 전송 완료 이후, 애플뮤직 앱으로 전환하는 뷰
struct ExportSuccessView: View {
    @EnvironmentObject var posterWrapper: PosterViewModelWrapper
    @EnvironmentObject var musicWrapper: MusicViewModelWrapper
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            
            Spacer().frame(height: 48)

            Image(asset: Asset.playlist)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 320, height: 320)

            Spacer()
            
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
            Spacer()

            BottomButton(title: "Apple Music으로 가기", kind: .line) {
                if let url = URL(string: "music://") {
                    UIApplication.shared.open(url)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .backgroundWithBlur()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        posterWrapper.shouldNavigateToMakePlaylist = false
                        posterWrapper.viewModel.clearText()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NavigationUtil.popToRootView()

                        }
                    },
                    label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.neu900)
                            .font(.system(size: 16, weight: .medium))
                    }
                )
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
