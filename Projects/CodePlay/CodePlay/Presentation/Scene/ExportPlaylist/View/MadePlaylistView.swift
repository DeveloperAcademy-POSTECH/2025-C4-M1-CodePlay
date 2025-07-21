//
//  SwiftUIView.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftUI

struct MadePlaylistView: View {
    @ObservedObject var wrapper: ExportPlaylistViewModelWrapper

    var body: some View {
            // 페스티벌 정보 영역
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // 포스터 이미지
                    Image("image_1")
                        .resizable(
                        )
                        .frame(width: 71, height: 88)
                        .overlay(
                            VStack {
                                Image(systemName: "music.note")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("FESTIVAL")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        )
                    
                    // 페스티벌 정보
                    VStack(alignment: .leading, spacing: 6) {
                        Text("2025 부산국제록페스티벌") // 추후 RawText의 첫번째 줄에서 가져오는걸로 수정 예정
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("뮤직페스티벌 삼락생태공원")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("2025.09.26.(금) ~ 2025.09.28(일)")
                            .font(.system(size: 12, weight: .bold))
                    }
                    
                    Spacer()
                    
                    // D-day 칩
                    HStack {
                        Text("D-24")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .clipShape(Capsule())
                    }
                }
                .padding(16)
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .background(Color.gray)
            }
            
            // 플레이리스트 영역
        VStack(spacing: 0) {
            // 헤더
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("2025 부산국제록페스티벌 플레이리스트")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)

                    Text("\(wrapper.playlistEntries.count) Songs")
                        .font(.system(size: 12))
                        .foregroundColor(.black)
                }

                Spacer()

                Button("편집") {
                    // 편집 기능은 스와이프로 대체 (swipeActions 사용)
                    // 추가 편집 모드가 필요하면 여기에 구현
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)

            // 리스트
            List {
                ForEach(wrapper.playlistEntries, id: \.id) { entry in
                    CustomList(
                        imageUrl: entry.albumArtworkUrl,
                        title: entry.trackTitle,
                        artist: entry.artistName,
                        trackId: entry.trackId,
                        isCurrentlyPlaying: wrapper.currentlyPlayingTrackId == entry.trackId,
                        isPlaying: wrapper.isPlaying,
                        onAlbumCoverTap: {
                            print("🎯 MadePlaylistView에서 탭 호출됨")
                            wrapper.togglePreview(for: entry.trackId)
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            print("🗑️ 삭제 버튼 탭됨 - \(entry.trackTitle)")
                            if let index = wrapper.playlistEntries.firstIndex(where: { $0.id == entry.id }) {
                                wrapper.deleteEntry(at: IndexSet(integer: index))
                            }
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
                .onDelete { indexSet in
                    print("🗑️ onDelete 호출됨")
                    wrapper.deleteEntry(at: indexSet)
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
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
            NavigationLink(destination: ExportLoadingView(wrapper: wrapper), isActive: $wrapper.isExporting) {
                EmptyView()
            }
        )
        .fullScreenCover(isPresented: $wrapper.isExportCompleted) {
            ExportSuccessView()
        }
    }
}


