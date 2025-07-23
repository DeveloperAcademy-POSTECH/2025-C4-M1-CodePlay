//
//  SwiftUIView.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftUI

struct MadePlaylistView: View {
    @EnvironmentObject var posterWrapper: PosterViewModelWrapper
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let groupedEntries: [String: [PlaylistEntry]] = Dictionary(
            grouping: wrapper.playlistEntries,
            by: { $0.artistName }
        )
        
        ZStack {
            // 🔵 배경 블러
            Color.clear
                .backgroundWithBlur()
            
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(groupedEntries.keys.sorted(), id: \.self) { artist in
                            Section(header:
                                Text(artist)
                                    .font(.title3)
                                    .bold()
                            ) {
                                ForEach(groupedEntries[artist] ?? []) { entry in
                                    CustomList(
                                        imageUrl: entry.albumArtworkUrl,
                                        title: entry.trackTitle,
                                        albumName: entry.albumName
                                    )
                                    .liquidGlass()
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 15)
                
                Spacer()
                
                BottomButton(title: "Apple Music으로 전송") {
                    wrapper.exportToAppleMusic()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("플레이리스트")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    posterWrapper.shouldNavigateToMakePlaylist = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
        }
        .background(
            NavigationLink(destination: ExportLoadingView(), isActive: $wrapper.isExporting) {
                EmptyView()
            }
        )
        .fullScreenCover(isPresented: $wrapper.isExportCompleted) {
            ExportSuccessView()
        }
    }

}

