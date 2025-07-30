//
//  CustomList.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI

struct CustomList: View {
    let imageUrl: String             // 앨범 커버 URL
    let title: String                // 노래 제목
    let albumName: String            // 앨범 이름 (또는 가수 이름)
    let trackId: String              // 트랙 ID (미리듣기용)
    let isCurrentlyPlaying: Bool     // 현재 재생 중인지 여부
    let isPlaying: Bool              // 재생 상태
    let playbackProgress: Double     // 재생 진행률 (0.0 ~ 1.0)
    let onAlbumCoverTap: () -> Void // 앨범 커버 탭 액션
    let onDeleteTap: (() -> Void)?   // 삭제 버튼 탭 액션 (옵셔널)

    var body: some View {
        HStack(spacing: 8) {
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
                
                // 재생 중일 경우: 진행률 + 재생버튼 오버레이
                if isCurrentlyPlaying {
                    // 배경 원 (48x48 크기로 고정하여 앨범 커버와 동일)
                    if isPlaying {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 40, height: 40)
                        
                        // 진행률 원 (더 작게 조정)
                        Circle()
                            .trim(from: 0, to: playbackProgress)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: playbackProgress)
                    }
                    
                    // 재생/일시정지 아이콘 (크기 고정)
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.7))
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    }
                }
            }
            
            // 제목 + 앨범명
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.BlgBold())
                    .foregroundColor(.neu900)
                
                Text(albumName)
                    .font(.BsmRegular())
                    .foregroundColor(.neu700)
            }
            
            Spacer()
            
            // 휴지통 아이콘 (삭제 기능용)
            if let onDeleteTap = onDeleteTap {
                Button(action: onDeleteTap) {
                    Image(systemName: "trash")
                        .foregroundColor(.neu700)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(style: .list)
        .onTapGesture {
            onAlbumCoverTap()
        }
    }
}
// MARK: - 기존 init 호환용 (간단한 리스트만 쓸 때)
extension CustomList {
    init(imageUrl: String, title: String, artist: String) {
        self.imageUrl = imageUrl
        self.title = title
        self.albumName = artist
        self.trackId = ""
        self.isCurrentlyPlaying = false
        self.isPlaying = false
        self.playbackProgress = 0.0
        self.onAlbumCoverTap = {}
        self.onDeleteTap = nil
    }
}

#Preview {
    ZStack {
        Color.blue
            .ignoresSafeArea()

        VStack {
            CustomList(
                imageUrl: "https://example.com/album.jpg",
                title: "Sample Song",
                albumName: "Sample Album",
                trackId: "sample123",
                isCurrentlyPlaying: true,
                isPlaying: true,
                playbackProgress: 0.3,
                onAlbumCoverTap: {
                },
                onDeleteTap: {
                }
            )
            CustomList(
                imageUrl: "https://example.com/album.jpg",
                title: "Sample Song 2",
                albumName: "Sample Album 2",
                trackId: "sample456",
                isCurrentlyPlaying: false,
                isPlaying: false,
                playbackProgress: 0.0,
                onAlbumCoverTap: {
                },
                onDeleteTap: {
                }
            )
        }
    }
}
