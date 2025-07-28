//
//  FestivalNoneView.swift
//  CodePlay
//
//  Created by 서연 on 7/29/25.
//

import SwiftUI
import SwiftData
import MusicKit

struct FestivalNoneView: View {
    var body: some View {
        ZStack (alignment : .bottom){
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()
            VStack(alignment: .center){
                
                Spacer()
                
                Text("페스티벌 인식에 실패했습니다")
                    .font(.HlgBold())
                    .foregroundColor(Color.neu900)

                Spacer().frame(height: 6)

                Text("페스티벌 라인업 포스터를 다시 촬영해 주세요")
                    .font(.BmdRegular())
                    .foregroundColor(Color.neu700)
                
                Spacer()
                
            Image("Festivalfail")
                    .resizable()
                    .scaledToFit( )
                    .frame(width: 240, height: 240)
                
                Spacer()
                
                BottomButton(title: "다시 촬영하기", kind: .line) {
                   // ㅎㅎ
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                    },
                    label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.neu900)
                    }
                )
            }
        }
    }
}

#Preview {
    FestivalNoneView()
}
