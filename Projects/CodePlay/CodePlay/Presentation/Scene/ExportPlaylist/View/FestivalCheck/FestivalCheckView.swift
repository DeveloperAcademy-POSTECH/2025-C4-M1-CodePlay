//
//  FestivalCheckView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI

struct FestivalCheckView: View {
    @State private var festival: PosterItemModel?  // 단일 객체로 변경

    var body: some View {
        ZStack {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()
            
            VStack {
                Spacer().frame(height: 56)

                Text("인식한 페스티벌 정보가 맞나요?")
                Text("아니오를 하면 수기로 입력하게 됩니다.")
                
                Spacer().frame(height: 36)
                
                if let festival = festival {
                    ArtistCard(
                        imageUrl: festival.currentImageURL?.absoluteString,
                        date: festival.date,
                        title: festival.title,
                        subTitle: festival.subtitle
                    )
                } else {
                    // 기본 카드 또는 로딩 상태
                    ArtistCard(
                        imageUrl: nil,
                        date: "2025.09.26.(금) ~ 2025.09.28(일)",
                        title: "2025 부산국제록페스티벌",
                        subTitle: "86 Songs"
                    )
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 999)
                                .fill(Color.clear)
                                .frame(height: 60)
                                .border(Color.gray, width: 1)
                            
                            Text("아니요")
                                .padding(.vertical, 18)
                                .zIndex(1)
                        }
                    })
                    
                    
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 999)
                                .fill(Color.clear)
                                .frame(height: 60)
                                .border(Color.gray, width: 1)
                            
                            Text("맞아요")
                                .padding(.vertical, 18)
                                .zIndex(1)

                        }
                    })
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 50)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    FestivalCheckView()
}
