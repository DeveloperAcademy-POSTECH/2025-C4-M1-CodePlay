//
//  OverlappingCardsView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/22/25.
//

import SwiftData
import SwiftUI

struct OverlappingCardsView: View {
    @State private var playlists: [Playlist]
    @State private var currentIndex = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var imageTimer: Timer?
    @State private var imageIndices: [Int]  // 각 플레이리스트의 현재 이미지 인덱스를 추적하기 위한 배열
    @Query var allEntries: [PlaylistEntry]
    @State private var selectedPlaylist: Playlist?
    @State private var isNavigateToDetail = false  //임시입니다

    let wrapper: MusicViewModelWrapper  //임시입니다.

    init(playlists: [Playlist], wrapper: MusicViewModelWrapper) {
        self._playlists = State(initialValue: playlists)
        self._imageIndices = State(
            initialValue: Array(repeating: 0, count: playlists.count)
        )
        self.wrapper = wrapper  //임시입니다.
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let cardWidth = geometry.size.width * 0.8

                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: -10) {
                            ForEach(
                                Array(playlists.enumerated()),
                                id: \.element.id
                            ) { index, playlist in
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
                                    let matchingEntries = allEntries.filter {
                                        $0.playlistId == playlist.id
                                    }

                                    ArtistCard(
                                        imageUrl: currentImageURL(
                                            for: playlist,
                                            at: index
                                        ),
                                        date: playlist.period ?? "",
                                        title: playlist.title,
                                        subTitle: "\(matchingEntries.count)곡"
                                    )
                                    .frame(width: cardWidth, height: 420)
                                    .scaleEffect(
                                        1.0 - normalizedDistance * 0.1
                                    )
                                    .animation(
                                        .easeOut(duration: 0.2),
                                        value: normalizedDistance
                                    )
                                    .onChange(of: minX) { _ in
                                        let globalFrame = cardGeometry.frame(
                                            in: .global
                                        )
                                        let screenCenter =
                                            UIScreen.main.bounds.width / 2
                                        let cardCenter = globalFrame.midX

                                        if abs(cardCenter - screenCenter)
                                            < cardWidth / 3
                                            && currentIndex != index
                                        {
                                            currentIndex = index
                                        }
                                    }
                                }
                                .frame(width: cardWidth, height: 420)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(
                                            phase.isIdentity ? 1.0 : 0.95
                                        )
                                        .opacity(phase.isIdentity ? 1.0 : 0.7)
                                }
                                .id(index)
                                .onTapGesture {
                                    if currentIndex != index {
                                        currentIndex = index
                                        proxy.scrollTo(index, anchor: .center)
                                    } else {
                                        selectedPlaylist = playlist
                                        isNavigateToDetail = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollTargetLayout()
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

            NavigationLink(
                isActive: $isNavigateToDetail,
                destination: {
                    if let selected = selectedPlaylist {
                        MadePlaylistView(playlist: selected)
                            .environmentObject(wrapper)
                    } else {
                        EmptyView()
                    }
                },
                label: {
                    EmptyView()
                }
            )
            .hidden()
            //            NavigationLink( //임시입니다진짜로
            //                isActive: $isNavigateToDetail,
            //                destination: {
            //                    if let selected = selectedPlaylist {
            //                        PlaylistDetailView(playlist: selected)
            //                            .environmentObject(wrapper)
            //                    } else {
            //                        EmptyView()
            //                    }
            //                },
            //                label: {
            //                    EmptyView()
            //                }
            //            )
            //            .hidden()
        }
    }
    private func printPlaylistInfo(_ playlist: Playlist) {
        print("🧾 Playlist 정보")
        print("🟢 title: \(playlist.title)")
        print("📍 place: \(playlist.place ?? "nil")")
        print("📅 period: \(playlist.period ?? "nil")")
        print("🎤 cast: \(playlist.cast ?? "nil")")
        print("🆔 id: \(playlist.id)")
        print("🕒 createdAt: \(playlist.createdAt)")

        let matchingEntries = allEntries.filter { $0.playlistId == playlist.id }

        print("🎶 Entries: (\(matchingEntries.count)곡)")
        for entry in matchingEntries {
            print(
                """
                ---
                🎤 artist: \(entry.artistName)
                artistartwork: \(entry.profileArtworkUrl)
                🎵 title: \(entry.trackTitle)
                💿 album: \(entry.albumName)
                🆔 trackId: \(entry.trackId)
                🔗 preview: \(entry.trackPreviewUrl)
                🖼 artwork: \(entry.albumArtworkUrl ?? "nil")
                📅 createdAt: \(entry.createdAt)
                """
            )
        }
    }

    private func currentImageURL(for playlist: Playlist, at index: Int)
        -> String?
    {
        let matchingEntries = allEntries.filter { $0.playlistId == playlist.id }
        let artworkURLs = matchingEntries.compactMap { $0.profileArtworkUrl }

        guard !artworkURLs.isEmpty else { return nil }

        let currentIdx = imageIndices[index]
        return artworkURLs[currentIdx % artworkURLs.count]
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
        let matchingEntries = allEntries.filter {
            $0.playlistId == playlists[index].id
        }
        guard !matchingEntries.isEmpty else { return }

        imageIndices[index] = Int.random(in: 0..<matchingEntries.count)
    }

    // 2초마다 현재 선택된 카드의 이미지 변경 타이머 시작
    private func startImageTimer() {
        stopImageTimer()
        imageTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true)
        { _ in
            changeImageForCard(at: currentIndex)
        }
    }

    // 타이머 중지
    private func stopImageTimer() {
        imageTimer?.invalidate()
        imageTimer = nil
    }
}
