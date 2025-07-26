//
//  BottomButton.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI

enum ButtonKind{
    case colorFill
    case line
}

// MARK: BottomButton - 하단 버튼 컴포넌트
struct BottomButton: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let kind: ButtonKind
    let action: () -> Void
    
    
    init(title: String, kind: ButtonKind, action: @escaping () -> Void) {
        self.title = title
        self.kind = kind
        self.action = action
    }
    
    private var mainGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [

                Color("Primary"),
                Color("Secondary")
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // TODO: HI-FI 컬러 확정 후 수정 예정
    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .blue
    }
   
    var body: some View {
        ZStack {
            let capsuleShape = RoundedRectangle(cornerRadius: 999)

            switch kind {
            case .colorFill:
                capsuleShape
                    .fill(mainGradient)
            case .line:
                capsuleShape
                    .fill(Color.clear)
                    .overlay(
                        capsuleShape
                            .stroke(mainGradient, lineWidth: 2)
                    )
            }

            Button(action: action) {
                Text(title)
                    .font(.BlgBold())
                    .fontWeight(.bold)
                    .foregroundStyle(kind == .colorFill ? Color.white : Color("Primary"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 999))
        .frame(maxWidth: .infinity, maxHeight: 60)
        .padding(.horizontal, 20)
    }
}


#Preview {
    BottomButton(
        title: "페스티벌 라인업 인식",
        kind: .colorFill,
        action: {
            print("버튼 누름")
        }
    )
    BottomButton(
        title: "페스티벌 라인업 인식",
        kind: .line,
        action: {
            print("버튼 누름")
        }
    )
}

