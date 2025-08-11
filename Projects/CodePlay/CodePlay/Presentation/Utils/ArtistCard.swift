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
    

    private func shortenedTitle(_ title: String) -> String {
     
        let keywords = ["with", "featuring", "x", "×", "presents", "주최", "후원"]
        
        for keyword in keywords {
            let components = title.components(separatedBy: keyword)
            if components.count > 1 {
        
                let afterKeyword = components[1].trimmingCharacters(in: .whitespaces)
                let beforeKeyword = components[0].trimmingCharacters(in: .whitespaces)
                
                if afterKeyword.count > beforeKeyword.count && 
                   (afterKeyword.localizedCaseInsensitiveContains("페스티벌") || 
                    afterKeyword.localizedCaseInsensitiveContains("festival")) {
                    return afterKeyword
                }
            }
        }
        
        return title
    }
    
    // TODO: ArtistImg를 대체할 빈 화면 보여주는 로직으로 수정해야 함
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
                                                    Image("ArtistImg")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .clipped()
                                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                                        .padding(12)
                                                }
                                            }
                                        } else {
                                            Image("ArtistImg2")
                                                .resizable()
                                                .scaledToFit()
                                                .clipped()
                                                .padding(12)
                                        }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image("ArtistImg2")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 296, height: 296)
                                    .padding(12)
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
                    
                    Text(shortenedTitle(title))
                        .font(.BlgBold())
                        .foregroundColor(.neu900)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                    Text(subTitle)
                        .font(.BsmRegular())
                        .foregroundColor(.neu700)
                }
                .padding(.leading, 12)
                .padding(.bottom, 18)
            }
            .liquidGlass(style: .card)
        }
        // .frame(maxWidth: 320, maxHeight: 420)
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
