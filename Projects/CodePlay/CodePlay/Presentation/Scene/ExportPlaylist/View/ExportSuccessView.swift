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

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Text("🎉 전송이 완료되었습니다!")
                    .font(.title2)
                    .multilineTextAlignment(.center)

                BottomButton(title: "Apple Music으로 이동") {
                    if let url = URL(string: "music://") {
                        UIApplication.shared.open(url)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .navigationTitle("전송 완료")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .backgroundWithBlur()
        }
    }
}
