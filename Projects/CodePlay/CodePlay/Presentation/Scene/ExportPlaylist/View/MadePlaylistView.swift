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

        ZStack(alignment: .bottom) {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(groupedEntries.keys.sorted(), id: \.self) { artist in
                            PlaylistSectionView(artist: artist, entries: groupedEntries[artist] ?? [], wrapper: wrapper)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 142)
                }
            }
            BottomButton(title: "Apple Music으로 전송", kind: .colorFill) {
                wrapper.exportToAppleMusic()
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
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.neu900)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    posterWrapper.shouldNavigateToMakePlaylist = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.neu900)
                }
            }
        }
        .fullScreenCover(isPresented: $wrapper.isExportCompleted) {
            ExportSuccessView()
        }
        .onAppear {
            UINavigationBar.applyLiquidGlassStyle()
        }

        NavigationLink(destination: ExportLoadingView(), isActive: $wrapper.isExporting) {
            EmptyView()
        }
        .hidden()
    }
}



