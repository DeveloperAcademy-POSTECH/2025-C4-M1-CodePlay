//
//  SwiftUIView.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftUI

struct MadePlaylistView: View {
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    
    var body: some View {
        let groupedEntries: [String: [PlaylistEntry]] = Dictionary(
            grouping: wrapper.playlistEntries,
            by: { $0.artistName }
        )
        
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
                                    artist: entry.artistName
                                )
                            }
                        }
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 15)
        }
        
        Spacer()
        
        // Apple Music 내보내기 버튼
        BottomButton(title: "Apple Music으로 전송") {
            wrapper.exportToAppleMusic()
        }
        .padding(.horizontal, 16)// Home Indicator 공간
        
        .background(Color.white)
        .navigationTitle("플레이리스트")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // 뒤로가기 액션
                }) {
                    Image(systemName: "chevron.left")
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
