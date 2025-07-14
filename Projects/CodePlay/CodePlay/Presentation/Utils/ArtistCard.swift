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
            Rectangle()
                .padding(.horizontal, 24)
                .foregroundStyle(.clear)
                .background(Color(red: 0.87, green: 0.87, blue: 0.87).opacity(0.1))
                .cornerRadius(20)
                .blur(radius: 100)
                .frame(maxWidth: .infinity, maxHeight: 420)
            
            VStack(alignment: .leading, spacing: 4) {
                Image("ArtistImg")
                    .frame(maxWidth: 256, maxHeight: 256)
                
                Spacer().frame(height: 24)
                
                Text(date)
                    .foregroundStyle(fontColor)
                
                Text(title)
                    .foregroundStyle(fontColor)

                Text(subTitle)
                    .foregroundStyle(fontColor)
            }
        }
    }
}

#Preview {
    ArtistCard(imageUrl: nil, date: "2025.09.26.(금) ~ 2025.09.28(일)", title: "2025 부산국제록페스티벌", subTitle: "86 Songs")
}
