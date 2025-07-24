//
//  OverlappingCardsView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/22/25.
//
import SwiftUI

struct OverlappingCardsView: View {
    let festivals: [PosterItemModel]
    @State private var currentIndex = 0
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width * 0.8

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -10) {
                            ForEach(
                                Array(festivals.enumerated()),
                                id: \.element.id
                            ) { index, info in
                                GeometryReader { cardGeometry in
                                    let minX = cardGeometry.frame(in: .global)
                                        .minX
                                    let screenCenter =
                                        UIScreen.main.bounds.width / 2
                                    let cardCenter = minX + cardWidth / 2
                                    let distance = abs(
                                        cardCenter - screenCenter
                                    )
                                    let normalizedDistance = min(
                                        distance / (cardWidth / 2),
                                        1.0
                                    )

                                    ArtistCard(
                                        imageUrl: info.imageURL?.absoluteString,
                                        date: info.date,
                                        title: info.title,
                                        subTitle: info.subtitle
                                    )
                                    .frame(width: cardWidth, height: 420)
                                    .scaleEffect(
                                        1.0 - normalizedDistance * 0.1
                                    )  // 중앙에 가까울수록 크게
                                    .animation(
                                        .easeOut(duration: 0.2),
                                        value: normalizedDistance
                                    )
                                    .onChange(of: minX) { _ in
                                        updateCurrentIndex(
                                            cardGeometry: cardGeometry,
                                            index: index,
                                            cardWidth: cardWidth
                                        )
                                    }
                                }
                                .frame(width: cardWidth, height: 420)
                                .id(index)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        currentIndex = index
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                    }
                    .padding(.bottom, 20)
                    .onAppear {
                        // 첫 번째 카드를 중앙에 배치
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(0, anchor: .center)
                        }
                    }
                }
            }
            .frame(height: 420)

            /// 인디케이터 컴포넌트
            HStack {
                ForEach(0..<festivals.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == currentIndex
                                ? Color.black : Color.gray.opacity(0.3)
                        )
                        .frame(width: index == currentIndex ? 32 : 8, height: 8)
                        .animation(
                            .easeInOut(duration: 0.3),
                            value: currentIndex
                        )
                }

            }
        }
    }

    private func updateCurrentIndex(
        cardGeometry: GeometryProxy,
        index: Int,
        cardWidth: CGFloat
    ) {
        let globalFrame = cardGeometry.frame(in: .global)
        let screenCenter = UIScreen.main.bounds.width / 2
        let cardCenter = globalFrame.midX
        let distance = abs(cardCenter - screenCenter)

        if distance < cardWidth / 4 {
            if currentIndex != index {
                currentIndex = index
            }
        }
    }
}
