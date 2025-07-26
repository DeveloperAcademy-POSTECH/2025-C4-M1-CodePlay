//
//  FestivalCheckView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI

struct FestivalCheckView: View {
    @State private var isNavigate: Bool = false
    let festival: PosterItemModel

    var body: some View {
        ZStack {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 56)

                Text("인식한 페스티벌 정보가 맞나요?")
                    .font(.HlgBold())
                    .foregroundColor(Color.neu900)

                Spacer().frame(height: 6)

                Text("아니오를 하면 수기로 입력하게 됩니다.")
                    .font(.BmdRegular())
                    .foregroundColor(Color.neu700)

                Spacer().frame(height: 36)

                    ArtistCard(
                        imageUrl: festival.currentImageURL?.absoluteString,
                        date: festival.date,
                        title: festival.title,
                        subTitle: festival.subtitle
                    )

                Spacer()
                
                HStack(spacing :2) {
                    BottomButton(title : "아니요", kind: .line ) {
                    }
                    
                    Spacer()
                    
                    BottomButton(title : "맞아요", kind: .colorFill){
                        isNavigate = true
                    }
                    
                }
//                .padding(.horizontal, 16)
            }
            .padding(.bottom, 50)


            
            NavigationLink(
                destination: FestivalSearchView(festival: festival),
                isActive: $isNavigate
            ) {
                EmptyView()
            }
        }
//        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)

    }
}

//#Preview {
//    FestivalCheckView()
//}
