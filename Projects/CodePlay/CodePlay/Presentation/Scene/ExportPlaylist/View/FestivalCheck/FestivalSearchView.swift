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
    @State private var isNavigate: Bool = false
    @FocusState private var isSearchFocused: Bool
    let suggestTitles: SuggestTitlesModel

    var body: some View {
        ZStack {
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()

            if showSearchResults {
                searchResultView
            } else {
                searchBeforeView
            }
            
//            NavigationLink(
//                destination: SelectArtistView(festival: festival),
//                isActive: $isNavigate
//            ) {
//                EmptyView()
//            }.hidden()
        }
        .safeAreaInset(edge: .top) {
            Divider()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // TODO: 특정뷰로 이동하도록 로직 수정 필요
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        if showSearchResults {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSearchResults = false
                                searchText = ""
                            }
                        } else {
                            dismiss()
                        }
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                )
            }

            ToolbarItem(placement: .principal) {
                SearchTextField(
                    text: $searchText,
                    isSearchFocused: $isSearchFocused,
                    onSearchSubmit: performSearch
                )
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("취소") {
                    if showSearchResults {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSearchResults = false
                        }
                    }
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

    // MARK: searchResultsView
    @ViewBuilder
    private var searchBeforeView: some View {
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
                    ForEach(suggestTitles.titles, id: \.self) { searchTerm in
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

    @ViewBuilder
    private var searchResultView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 26)

            LazyVStack(spacing: 12) {
                ForEach(filteredResults, id: \.self) { result in
                    Button(action: {
                        isNavigate = true
                    }, label: {
                        HStack {
                            Text(result)
                                .font(.BlgBold())
                                .foregroundColor(Color.neutral700)
                                .lineSpacing(2)
                                .padding(.leading, 12)
                                .padding(.vertical, 13)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.9), lineWidth: 2)
                        )
                        .background(.white.opacity(0.3))
                        .cornerRadius(12)
                    })
                }
            }
            .padding(.horizontal, 18)

            Spacer()
        }
    }
    
    private var filteredResults: [String] {
        suggestTitles.titles.filter { $0.contains(searchText) }
    }
    
    /// 검색어와 일치하는 결과가 있는지 확인하는 함수
    private func performSearch() {
        if !searchText.isEmpty {
            let hasResults = suggestTitles.titles.contains {
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
    let onSearchSubmit: () -> Void

    var body: some View {
        HStack {
            TextField("페스티벌 이름을 입력하세요", text: $text)
                .focused($isSearchFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.BmdRegular())
                .onSubmit {
                    onSearchSubmit()
                }

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
