//
//  OverlappingCardsView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/22/25.
//

import SwiftUI

struct OverlappingCardsView: View {
    @State private var playlists: [Playlist]
    @State private var currentIndex = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var imageTimer: Timer?
    @State private var imageIndices: [Int] // 각 플레이리스트의 현재 이미지 인덱스를 추적하기 위한 배열
    
    init(playlists: [Playlist]) {
        self._playlists = State(initialValue: playlists)
        self._imageIndices = State(initialValue: Array(repeating: 0, count: playlists.count))
    }
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width * 0.8
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -16) {
                            ForEach(
                                Array(playlists.enumerated()),
                                id: \.element.id
                            ) { index, playlist in
                                GeometryReader { cardGeometry in
                                    let minX = cardGeometry.frame(in: .global).minX
                                    let screenCenter = UIScreen.main.bounds.width / 2
                                    let cardCenter = minX + cardWidth / 2
                                    let distance = abs(cardCenter - screenCenter)
                                    let normalizedDistance = min(distance / (cardWidth / 2), 1.0)
                                    
                                    ArtistCard(
                                        imageUrl: currentImageURL(for: playlist, at: index),
                                        date: playlist.period ?? "",
                                        title: playlist.title,
                                        subTitle: playlist.place ?? ""
                                    )
                                    .frame(width: cardWidth, height: 420)
                                    .scaleEffect(1.0)
                                    .animation(
                                        .easeOut(duration: 0.2),
                                        value: normalizedDistance
                                    )
                                    .onChange(of: minX) { _ in
                                        let globalFrame = cardGeometry.frame(in: .global)
                                        let screenCenter = UIScreen.main.bounds.width / 2
                                        let cardCenter = globalFrame.midX
                                        
                                        if abs(cardCenter - screenCenter) < cardWidth / 3 && currentIndex != index {
                                            currentIndex = index
                                        }
                                    }
                                }
                                .frame(width: cardWidth, height: 420)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                                        .opacity(phase.isIdentity ? 1.0 : 0.7)
                                }
                                .id(index)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        if currentIndex != index {
                                            currentIndex = index
                                            proxy.scrollTo(index, anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollTargetLayout()
                    .padding(.bottom, 20)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            proxy.scrollTo(0, anchor: .center)
                        }
                        // 2초 타이머 시작
                        startImageTimer()
                    }
                    .onDisappear {
                        // 뷰가 사라질 때 타이머 중지
                        stopImageTimer()
                    }
                }
            }
            .frame(height: 420)
            
            HStack {
                ForEach(0..<playlists.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == currentIndex
                            ? Color("Primary") : Color.gray.opacity(0.3)
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
    
    private func currentImageURL(for playlist: Playlist, at index: Int) -> String? {
        let artworkURLs = playlist.entries.compactMap { $0.albumArtworkUrl }
        guard !artworkURLs.isEmpty, imageIndices[index] < artworkURLs.count else { return nil }
        return artworkURLs[imageIndices[index]]
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
    
    // 특정 인덱스의 카드 이미지를 다음 이미지로 변경
    private func changeImageForCard(at index: Int) {
        guard index < playlists.count else { return }
        let artworkURLs = playlists[index].entries.compactMap { $0.albumArtworkUrl }
        guard !artworkURLs.isEmpty else { return }
        imageIndices[index] = (imageIndices[index] + 1) % artworkURLs.count
    }
    
    // 2초마다 현재 선택된 카드의 이미지 변경 타이머 시작
    private func startImageTimer() {
        stopImageTimer()
        imageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            changeImageForCard(at: currentIndex)
        }
    }
    
    // 타이머 중지
    private func stopImageTimer() {
        imageTimer?.invalidate()
        imageTimer = nil
    }
}
