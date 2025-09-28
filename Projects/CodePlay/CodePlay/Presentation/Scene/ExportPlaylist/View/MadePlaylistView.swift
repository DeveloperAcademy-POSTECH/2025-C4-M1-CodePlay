//
//  SwiftUIView.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftData
import SwiftUI

struct MadePlaylistView: View {
    @EnvironmentObject var posterWrapper: PosterViewModelWrapper
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @Environment(\.dismiss) var dismiss
    @Query var allEntries: [PlaylistEntry]

    let selectedPlaylist: Playlist?

    init(selectedPlaylist: Playlist?) {
        self.selectedPlaylist = selectedPlaylist
    }

    init(playlist: Playlist) {
        self.selectedPlaylist = playlist
    }

    var body: some View {
        let playlistEntries: [PlaylistEntry] = {
            if let selectedPlaylist = selectedPlaylist {
                // 선택된 플레이리스트의 엔트리들만 필터링
                let filteredEntries = allEntries.filter {
                    $0.playlistId == selectedPlaylist.id
                }
                Log.debug(
                    "🎵 선택된 플레이리스트(\(selectedPlaylist.title))의 엔트리 수: \(filteredEntries.count)"
                )
                Log.debug("🔍 전체 엔트리 수: \(allEntries.count)")
                Log.debug("🆔 찾는 playlistId: \(selectedPlaylist.id)")

                // 모든 엔트리의 playlistId 출력
                for entry in allEntries {
                    Log.debug(
                        "📦 Entry: \(entry.artistName) - playlistId: \(entry.playlistId)"
                    )
                }

                return filteredEntries
            } else {
                // 기존 동작: wrapper에서 가져온 엔트리들 사용
                Log.debug("🎵 Wrapper에서 가져온 엔트리 수: \(wrapper.playlistEntries.count)")
                return wrapper.playlistEntries
            }
        }()

        let groupedEntries: [String: [PlaylistEntry]] = Dictionary(
            grouping: playlistEntries,
            by: { $0.artistName }
        )

        ZStack(alignment: .bottom) {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(groupedEntries.keys.sorted(), id: \.self) {
                            artist in
                            PlaylistSectionView(
                                artist: artist,
                                entries: groupedEntries[artist] ?? [],
                                wrapper: wrapper
                            )
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 142)
                }
            }
            BottomButton(title: "Apple Music으로 전송", kind: .colorFill) {
                // MadePlaylistView에서 보여지는 정렬된 순서 그대로 내보내기
                let sortedEntries = groupedEntries.keys.sorted().flatMap { artist in
                    groupedEntries[artist] ?? []
                }
                wrapper.exportToAppleMusicWithSortedOrder(sortedEntries: sortedEntries)
            }
            .padding(.bottom, 50)
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .liquidGlass(style: .listbutton)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("플레이리스트")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("플레이리스트")
                    .font(.BlgBold())
                    .foregroundColor(.neu900)
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    switch wrapper.entrySource {
                    case .main:
                        NavigationUtil.popToRootView()
                    case .export:
                        NavigationUtil.popToView(at: 2)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.neu900)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    posterWrapper.shouldNavigateToMakePlaylist = false
                    NavigationUtil.popToRootView()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.neu900)
                }
            }
        }
        .onAppear {
            wrapper.currentlyPlayingTrackId = nil
            wrapper.isPlaying = false
            wrapper.playbackProgress = 0.0
        }

        NavigationLink(
            destination: ExportLoadingView(),
            isActive: $wrapper.isExporting
        ) {
            EmptyView()
        }
        .hidden()

        .onAppear {
            wrapper.isExportCompleted = false
        }
    }
}
