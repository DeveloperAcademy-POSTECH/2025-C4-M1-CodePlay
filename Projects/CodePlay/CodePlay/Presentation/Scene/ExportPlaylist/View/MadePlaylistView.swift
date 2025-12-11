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
    @Environment(\.modelContext) private var modelContext
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
                if isPlaylistSavedInSwiftData(playlistId: selectedPlaylist.id) {
                    let filteredEntries = allEntries.filter {
                        $0.playlistId == selectedPlaylist.id
                    }
                    Log.debug("🎵 저장된 플레이리스트(\(selectedPlaylist.title))의 엔트리 수: \(filteredEntries.count)")
                    return filteredEntries
                } else {
                    Log.debug("🎵 임시 플레이리스트(\(selectedPlaylist.title))의 엔트리 수: \(wrapper.playlistEntries.count)")
                    return wrapper.playlistEntries
                }
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
                // 1. 먼저 플레이리스트를 SwiftData에 저장
                savePlaylistToDB()
                
                // 2. MadePlaylistView에서 보여지는 정렬된 순서 그대로 내보내기
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

        .navigationDestination(isPresented: $wrapper.isExporting) {
            ExportLoadingView()
        }

        .onAppear {
            wrapper.isExportCompleted = false
        }
    }
    private func savePlaylistToDB() {
        guard let playlist = selectedPlaylist else {
            Log.fault("❌ 저장할 플레이리스트가 없습니다")
            return
        }
        do {
            let playlistId = playlist.id
            let existingPlaylists = try modelContext.fetch(
                FetchDescriptor<Playlist>(
                    predicate: #Predicate<Playlist> { $0.id == playlistId }
                )
            )
            
            if !existingPlaylists.isEmpty {
                Log.debug("✅ 플레이리스트가 이미 저장되어 있음: \(playlist.title)")
                return
            }
        } catch {
            Log.fault("❌ 기존 플레이리스트 확인 중 오류: \(error.localizedDescription)")
        }

        modelContext.insert(playlist)
        
        do {
            try modelContext.save()
            Log.debug("✅ 플레이리스트 저장 완료: \(playlist.title)")
        } catch {
            Log.fault("❌ 플레이리스트 저장 실패: \(error.localizedDescription)")
        }
    }
    private func isPlaylistSavedInSwiftData(playlistId: UUID) -> Bool {
        do {
            let existingPlaylists = try modelContext.fetch(
                FetchDescriptor<Playlist>(
                    predicate: #Predicate<Playlist> { $0.id == playlistId }
                )
            )
            return !existingPlaylists.isEmpty
        } catch {
            Log.fault("❌ 플레이리스트 저장 여부 확인 중 오류: \(error.localizedDescription)")
            return false
        }
    }
}
