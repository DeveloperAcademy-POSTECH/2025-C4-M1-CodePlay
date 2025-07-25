//
//  ExportSuccessView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/21/25.
//

import SwiftUI
// MARK: 전송 완료 이후, 애플뮤직 앱으로 전환하는 뷰 (hifi 07_1부분)
struct ExportSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goToMain = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                Image("Playlist")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 320)
                
                
                Text("Apple Music에\n플레이리스트를 생성했어요!")
                    .font(.HlgBold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.neutral900)
                
                
                Text("애플 뮤직에서 생성된 플레이리스트를 확인해 보세요")
                    .font(.BmdRegular)
                    .foregroundColor(.neutral700)
                
                Spacer()
                
                BottomButton(title: "Apple Music으로 가기", kind: .line) {
                    if let url = URL(string: "music://") {
                        UIApplication.shared.open(url)
                    }
                }
                
                Spacer()
            }
            //            .navigationTitle("전송 완료")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        goToMain = true
                    }) {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(.neutral900)
                    }
                }
            }
            .backgroundWithBlur()
            NavigationLink(
                destination: MainPosterView()
                    .navigationBarBackButtonHidden(true),
                isActive: $goToMain,
                label: { EmptyView()
                } // 파일에서 뷰 이렇게 옮기면 안될 것 같은디 ㅜㅜ dismiss()
            )
        }
    }
}

#Preview {
    ExportSuccessView()
}
