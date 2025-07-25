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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.clear
                    .backgroundWithBlur()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    
                    Spacer().frame(height: 80)
                    
                    
                    Image("Playlist")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320, height: 320)
                    
                    
                    Spacer().frame(height: 96)
                    
                    
                    Text("Apple Music에\n플레이리스트를 생성했어요!")
                        .font(.KoddiUDOnGothic(.Bold, size: 24))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    Spacer().frame(height: 12)
                    
                    
                    Text("애플뮤직에서 생성된 플레이리스트를 확인해보세요.")
                        .font(.KoddiUDOnGothic(.regular, size: 14))
                        .multilineTextAlignment(.center)
                    
                    
                    Spacer().frame(height: 80)
                    
                    BottomButton(title: "Apple Music으로 가기", kind: .line) {
                        if let url = URL(string: "music://") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // MainView로 돌아가기 위해 모든 네비게이션 상태 초기화
                        posterWrapper.shouldNavigateToMakePlaylist = false
                        posterWrapper.viewModel.clearText()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ExportSuccessView()
}

