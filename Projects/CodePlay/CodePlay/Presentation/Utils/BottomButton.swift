//
//  BottomButton.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI

// MARK: BottomButton - 하단 버튼 컴포넌트
struct BottomButton: View {
    let title: String
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    // TODO: HI-FI 컬러 확정 후 수정 예정
    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .blue
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 999)
                .frame(maxHeight: 60)
                .padding(.horizontal, 16)

            Button(action: {
                action()
            }, label: {
                Text(title)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 87)
                    .padding(.vertical, 18)
            })
        }
    }
}

#Preview {
    BottomButton(
        title: "페스티벌 라인업 인식",
        action: {
            print("버튼 누름")
        }
    )
}
