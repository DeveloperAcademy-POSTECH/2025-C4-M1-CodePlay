//
//  CustomList.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/14/25.
//

import SwiftUI
import UIKit

struct CustomList: View {
    let imageUrl: String // 이미지 url
    let title: String // 노래 제목
    let artist: String // 가수 이름
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.white)
                .cornerRadius(12)
                .frame(maxWidth: .infinity, maxHeight: 72, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 1)
            
            HStack(spacing: 8) {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 48, maxHeight: 48, alignment: .leading)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundStyle(.black)
                    
                    Spacer().frame(height: 4)
                    
                    Text(artist)
                        .foregroundStyle(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    CustomList(imageUrl: "ddd", title: "360", artist: "???")
}
