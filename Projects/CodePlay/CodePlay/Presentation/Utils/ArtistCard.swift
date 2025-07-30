//
//  ArtistCard.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI

struct ArtistCard: View {
    let imageUrl: String?
    let date: String
    let title: String
    let subTitle: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var fontColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var highQualityImageUrl: String? {
        return imageUrl?.appleMusicHighQualityImageURL(targetSize: 592)
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.clear)
                    .background(
                        Group {
                            if let highQualityUrl = highQualityImageUrl,
                               let url = URL(string: highQualityUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 296, height: 296)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .padding(12)
                                    case .failure:
                                        // 고화질 실패시 원본 URL로 재시도
                                        if let originalUrl = imageUrl,
                                           let fallbackUrl = URL(string: originalUrl) {
                                            AsyncImage(url: fallbackUrl) { fallbackPhase in
                                                switch fallbackPhase {
                                                case .success(let fallbackImage):
                                                    fallbackImage
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipped()
                                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                                        .padding(12)
                                                       
                                                default:
                                                    ProgressView()
                                                        .frame(width: 296, height: 296)
                                                }
                                            }
                                        } else {
                                            ProgressView()
                                                .frame(width: 296, height: 296)
                                        }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Text("이미지를 불러올 수 없습니다.")
                            }
                        }
                    )
                    .cornerRadius(16)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .neu1000.opacity(0.2), radius: 8, x: 0, y: 4)
                    .frame(width: 296, height: 296)
                
                Spacer().frame(height: 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(date)
                        .font(.BsmRegular())
                        .foregroundColor(.neu700)
                    
                    Text(title)
                        .font(.BlgBold())
                        .foregroundColor(.neu900)
                    
                    Text(subTitle)
                        .font(.BsmRegular())
                        .foregroundColor(.neu700)
                }
                .padding(.leading, 12)
                .padding(.bottom, 18)
            }
            .liquidGlass(style: .card)
        }
    }
}

#Preview {
    ArtistCard(
        imageUrl: nil,
        date: "2025.07.30",
        title: "썸머페스트",
        subTitle: "24곡"
    )
}
