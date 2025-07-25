//
//  FestivalSearchView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI

struct FestivalSearchView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var showSearchResults = false
    @FocusState private var isSearchFocused: Bool

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

    // 검색 결과 더미 데이터
    let searchResults = [
        "2025 부산국제록페스티벌",
        "2025 부산국제록페스티벌",
        "2025 부산국제록페스티벌",
        "2025 부산국제록페스티벌",
        "2025 부산국제록페스티벌",
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
                            .foregroundColor(Color.neutral900)
                            .font(.BmdBold())

                        Spacer()

                        Button(
                            action: {
                            },
                            label: {
                                Text("전체 삭제")
                                    .font(.BmdRegular())
                                    .foregroundColor(Color.neutral700)
                            }
                        )
                    }
                    LazyVGrid(
                        columns: [
                            GridItem(
                                .adaptive(minimum: 150),
                                alignment: .leading
                            )

                        ],
                        spacing: 12
                    ) {
                        ForEach(recommendedSearches, id: \.self) { searchTerm in
                            FestivalBox(title: searchTerm)
                                .onTapGesture {
                                    searchText = searchTerm
                                    performSearch()
                                }
                        }
                    }
                    .frame(alignment: .leading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
                .frame(alignment: .topLeading)
                .background(.white.opacity(0.6))
                .cornerRadius(20)

                Spacer()
            }
            .padding(.horizontal, 18)
        }
        .safeAreaInset(edge: .top) {
            Divider()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // TODO: 특정뷰로 이동하도록 로직 수정 필요
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }

            ToolbarItem(placement: .principal) {
                SearchTextField(
                    text: $searchText,
                    isSearchFocused: $isSearchFocused
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("취소") {
                    searchText = ""
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isSearchFocused = true
            }
        }
    }

    /// 검색어와 일치하는 결과가 있는지 확인하는 함수
    private func performSearch() {
        if !searchText.isEmpty {
            let hasResults = recommendedSearches.contains {
                $0.contains(searchText)
            }
            if hasResults {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSearchResults = true
                    isSearchFocused = false
                }
            }
        }
    }
}

// MARK: SearchTextField
struct SearchTextField: View {
    @Binding var text: String
    @FocusState.Binding var isSearchFocused: Bool

    var body: some View {
        HStack {
            TextField("페스티벌 이름을 입력하세요", text: $text)
                .focused($isSearchFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.BmdRegular())

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {

                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FestivalSearchView()
}
