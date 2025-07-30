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
                    .frame(width: 296, height: 296)
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
                                            .scaledToFill()
                                            .frame(width: 296, height: 296)
                                            .clipped()
                                    case .failure:
                                        // 고화질 실패시 원본 URL로 재시도
                                        if let originalUrl = imageUrl,
                                           let fallbackUrl = URL(string: originalUrl) {
                                            AsyncImage(url: fallbackUrl) { fallbackPhase in
                                                switch fallbackPhase {
                                                case .success(let fallbackImage):
                                                    fallbackImage
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 296, height: 296)
                                                        .clipped()
                                                default:
                                                    Text("이미지 로딩에 실패했습니다.")
//                                                        .resizable()
//                                                        .scaledToFit()
                                                        .frame(width: 296, height: 296)
                                                }
                                            }
                                        } else {
                                            Image("ArtistImg")
//                                                .resizable()
//                                                .scaledToFit()
                                                .frame(width: 296, height: 296)
                                        }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image("ArtistImg")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 296, height: 296)
                            }
                        }
                    )
                    .cornerRadius(16)
                    .shadow(color: .neu1000.opacity(0.2), radius: 8, x: 0, y: 4)
                
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
//        .frame(maxWidth: 320, maxHeight: 420)
    }
}
