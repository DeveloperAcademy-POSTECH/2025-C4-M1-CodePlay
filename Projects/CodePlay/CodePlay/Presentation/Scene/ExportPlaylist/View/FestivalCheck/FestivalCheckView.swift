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
                    .foregroundColor(Color.neutral900)

                Spacer().frame(height: 6)

                Text("아니오를 하면 수기로 입력하게 됩니다.")
                    .font(.BmdRegular())
                    .foregroundColor(Color.neutral700)

                Spacer().frame(height: 36)

                    ArtistCard(
                        imageUrl: festival.currentImageURL?.absoluteString,
                        date: festival.date,
                        title: festival.title,
                        subTitle: festival.subtitle
                    )

                Spacer()

                bottombutton
            }
            .padding(.bottom, 50)

            NavigationLink(
                destination: FestivalSearchView(festival: festival),
                isActive: $isNavigate
            ) {
                EmptyView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private var bottombutton: some View {
        HStack(spacing: 16) {
            Button(
                action: {

                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(Color.clear)
                            .frame(height: 60)
                            .shadow(
                                color: Color(
                                    red: 0,
                                    green: 0.65,
                                    blue: 1
                                ).opacity(0.16),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .inset(by: 1)
                                    .stroke(
                                        Color(
                                            red: 0.91,
                                            green: 0.45,
                                            blue: 0.93
                                        ),
                                        lineWidth: 2
                                    )
                            )

                        Text("아니요")
                            .font(.BlgBold())
                            .foregroundColor(Color.blue)
                            .padding(.vertical, 18)
                            .zIndex(1)
                    }
                }
            )

            Button(
                action: {
                    isNavigate = true
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(Color.clear)
                            .frame(height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .inset(by: 1)
                                    .fill(
                                        LinearGradient(
                                            stops: [
                                                Gradient.Stop(
                                                    color: Color(
                                                        red: 0.91,
                                                        green: 0.45,
                                                        blue: 0.93
                                                    ),
                                                    location: 0.00
                                                ),
                                                Gradient.Stop(
                                                    color: Color(
                                                        red: 0,
                                                        green: 0.65,
                                                        blue: 1
                                                    ),
                                                    location: 1.00
                                                ),
                                            ],
                                            startPoint: UnitPoint(
                                                x: 0,
                                                y: 0.5
                                            ),
                                            endPoint: UnitPoint(
                                                x: 1,
                                                y: 0.5
                                            )
                                        )
                                    )
                            )

                        Text("맞아요")
                            .foregroundColor(Color.white)
                            .font(.BlgBold())
                            .padding(.vertical, 18)
                            .zIndex(1)

                    }
                }
            )
        }
        .padding(.horizontal, 16)
    }
}

//#Preview {
//    FestivalCheckView()
//}
