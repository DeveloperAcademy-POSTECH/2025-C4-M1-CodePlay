//
//  SelectArtistView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/26/25.
//

import SwiftUI

struct SelectArtistView: View {
    @Environment(\.dismiss) var dismiss
    let festival: PosterItemModel

    var body: some View {
        ZStack(alignment: .leading) {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()
            
            VStack(alignment: .leading){
                Spacer().frame(height: 16)

                festivalInfoBox
                
                Spacer().frame(height: 24)
                
                ArtistGridView
                
                Spacer()
                
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden()
        .navigationTitle(Text("아티스트 선택"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        dismiss()
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                    },
                    label: {
                        Text("취소")
                            .foregroundColor(.black)
                    }
                )
            }

        }
    }
    
    @ViewBuilder
    private var festivalInfoBox: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            VStack(alignment: .leading) {
//                Text(festival.title)
//                    .font(.HmdBold())
//                    .foregroundColor(.black)
//                    .lineSpacing(2)
//                    
//                Text(festival.subtitle)
//                    .font(.BsmRegular())
//                    .foregroundColor(Color.neutral700)
//                    .lineSpacing(2)
//                
//                Text(festival.date)
//                    .font(.BsmRegular())
//                    .foregroundColor(Color.neutral700)
//                    .lineSpacing(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 15)
        }
        .frame(maxWidth: .infinity, maxHeight: 100, alignment: .leading)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.9), lineWidth: 2)
            
        )
        .background(.white.opacity(0.3))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var ArtistGridView: some View {
        
    }
}
