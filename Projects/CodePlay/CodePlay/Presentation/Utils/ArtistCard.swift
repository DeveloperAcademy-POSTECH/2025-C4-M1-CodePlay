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
    
    var body: some View {
        ZStack {
          
            VStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 296, height: 296)
                    .background(
                        Group {
                            
                            if let imageUrl = imageUrl {
                                
                                Image(imageUrl)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 296, height: 296)
                                    .clipped()
                            } else {
                                
                                Image("ArtistImg")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 296, height: 296)
                                    .clipped()
                            }
                        }
                    )
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Spacer().frame(height: 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(date)
                        .foregroundStyle(fontColor)
                    
                    Text(title)
                        .foregroundStyle(fontColor)
                    
                    Text(subTitle)
                        .foregroundStyle(fontColor)
                }
                .padding(.leading, 12)
                .padding(.bottom, 18)
            }
            .liquidGlass(style: .card)
        }
//        .liquidGlass(style: .card)
        .frame(maxWidth: 320, maxHeight: 420)
    }
}

#Preview {
    ZStack {
        Color.blue
            .ignoresSafeArea()
        ArtistCard(imageUrl: nil, date: "2025.09.26.(금) ~ 2025.09.28(일)", title: "2025 부산국제록페스티벌", subTitle: "86 Songs")
    }
}
