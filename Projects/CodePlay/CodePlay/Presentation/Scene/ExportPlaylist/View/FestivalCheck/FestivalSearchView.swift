//
//  FestivalSearchView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI

struct FestivalSearchView: View {
    @Environment(\.dismiss) var dismiss

    // 더미데이터
    let recommendedSearches = [
        "2025 부산국제록페스티벌",
        "2025 펜츠락페스티벌",
        "그랜드 민트 페스티벌 2...",
        "JUMF 2025 전주얼티밋...",
        "22회 자라섬재즈페스티벌",
        "집콕보 2025 밤밤밤페...",
        "경기인디뮤직페스티벌 2...",
        "2025 사운드 플래닛 페...",
    ]

    var body: some View {
        ZStack {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Spacer().frame(height: 26)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        Text("추천 검색어")
                        
                        Spacer()
                        
                        Text("전체 삭제")
                    }
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 150), alignment: .leading)

                        ],
                        spacing: 12
                    ) {
                        ForEach(recommendedSearches, id: \.self) { searchTerm in
                            FestivalBox(title: searchTerm)
                        }
                    }
                    .frame(alignment: .leading)                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .frame(alignment: .topLeading)
                .background(.white.opacity(0.4))
                .cornerRadius(20)
            }
            .padding(.horizontal, 18)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // TODO: 특정뷰로 이동하도록 로직 수정 필요
            ToolbarItem(placement: .navigationBarLeading) {
                Button("닫기") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("취소") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    FestivalSearchView()
}
