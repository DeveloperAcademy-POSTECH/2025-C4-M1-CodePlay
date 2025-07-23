//
//  CustomList.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI

struct CustomList: View {
    let imageUrl: String // 이미지 url
    let title: String    // 노래 제목
    let artist: String   // 가수 이름
    let trackId: String  // 트랙 ID (미리듣기용)
    let isCurrentlyPlaying: Bool // 현재 재생 중인지 여부
    let isPlaying: Bool // 재생 상태
    let playbackProgress: Double // 재생 진행률 (0.0 ~ 1.0)
    let onAlbumCoverTap: () -> Void // 앨범 커버 탭 액션

    var body: some View {
        Button(action: {
            onAlbumCoverTap()
        }) {
            HStack(spacing: 12) {
                // 앨범 커버 + 재생 버튼 오버레이
                ZStack {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 48, height: 48)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)

                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .clipped()
                                .cornerRadius(8)

                        case .failure:
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)

                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // 원형 프로그레스 바 (30초 진행률 표시)
                    if isCurrentlyPlaying && isPlaying {
                        // 배경 원 (회색)
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 3)
                            .frame(width: 56, height: 56)
                        
                        // 진행률 원 (하얀색)
                        Circle()
                            .trim(from: 0, to: playbackProgress)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 38, height: 38)
                            .rotationEffect(.degrees(-90)) // 12시 방향부터 시작
                            .animation(.linear(duration: 0.1), value: playbackProgress)
                    }
                    
                    // 재생/일시정지 버튼 오버레이
                    if isCurrentlyPlaying {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.7))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)

                    Text(artist)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 기존 이니셜라이저와의 호환성을 위한 extension
extension CustomList {
    init(imageUrl: String, title: String, artist: String) {
        self.imageUrl = imageUrl
        self.title = title
        self.artist = artist
        self.trackId = ""
        self.isCurrentlyPlaying = false
        self.isPlaying = false
        self.playbackProgress = 0.0
        self.onAlbumCoverTap = {}
    }
}

#Preview {
    CustomList(
        imageUrl: "https://example.com/album.jpg",
        title: "Sample Song",
        artist: "Sample Artist",
        trackId: "sample123",
        isCurrentlyPlaying: true,
        isPlaying: true,
        playbackProgress: 0.3,
        onAlbumCoverTap: {
            print("Album cover tapped")
        }
    )
}
