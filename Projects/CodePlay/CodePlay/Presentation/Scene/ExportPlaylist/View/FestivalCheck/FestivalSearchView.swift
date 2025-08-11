//
//  FestivalSearchView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI
import SwiftData

struct FestivalSearchView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var showSearchResults = false
    @State private var isNavigate: Bool = false
    @State private var searchResults: [String] = []
    @State private var selectedPlaylist: Playlist?
    @State private var savedPlaylist: Playlist?
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
            
            NavigationLink(
                destination: selectedPlaylist != nil ? AnyView(SelectArtistView(playlist: selectedPlaylist!)) : AnyView(EmptyView()),
                isActive: $isNavigate
            ) {
                EmptyView()
            }.hidden()
        }
        .safeAreaInset(edge: .top) {
            Divider()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(
                    action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSearchResults = false
                            searchText = ""
                            dismiss()
                        }
                    },
                    label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color("Primary"))
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
                Button(action: {
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            showSearchResults = false
//                            searchText = ""
//                            NavigationUtil.popToRootView()
//                        }
                    }) {
                    Text("취소")
                        .font(.BlgRegular())
                        .foregroundColor(.neu900.opacity(0)) // 일단은 비활성화

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
                        .foregroundColor(Color.neu900)
                        .font(.BmdBold())

                    Spacer()

                    Button(
                        action: {
                        },
                        label: {
                            Text("전체 삭제")
                                .font(.BmdRegular())
                                .foregroundColor(Color.neu700)
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
            .background(.neu0.opacity(0.6))
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
                ForEach(searchResults, id: \.self) { result in
                    Button(action: {
                        Task {
                            await fetchAndSavePlaylist(for: result)
                            if selectedPlaylist != nil {
                                isNavigate = true
                            }
                        }
                    }, label: {
                        HStack {
                            Text(result)
                                .font(.BlgBold())
                                .foregroundColor(Color.neu700)
                                .lineSpacing(2)
                                .padding(.leading, 12)
                                .padding(.vertical, 13)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .shadow(color: .neu1000.opacity(0.1), radius: 10, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.neu0.opacity(0.9), lineWidth: 2)
                        )
                        .background(.neu0.opacity(0.3))
                        .cornerRadius(12)
                    })
                }
            }
            .padding(.horizontal, 18)

            Spacer()
        }
    }
    /// 검색어와 일치하는 결과가 있는지 확인하는 함수
    private func performSearch() {
        if !searchText.isEmpty {
            Task {
                do {
                    let request = PostFestInfoTextRequestDTO(rawText: searchText)
                    let response = try await NetworkService.shared.festivalinfoService.postFestInfoText(model: request)
                    
                    searchResults = response.top5.map { $0.title }
                    
                    if !searchResults.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSearchResults = true
                            isSearchFocused = false
                        }
                    }
                } catch {
                    Log.fault("Search API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchAndSavePlaylist(for title: String) async {
        do {
            let request = PostFestInfoTextRequestDTO(rawText: title)
            let response = try await NetworkService.shared.festivalinfoService.postFestInfoText(model: request)
            
            if let data = response.dynamoData.first {
                let playlist = Playlist(
                    title: data.title,
                    period: data.period,
                    cast: data.cast,
                    festivalId: data.festivalId,
                    place: data.place
                )
                
                modelContext.insert(playlist)
                
                do {
                    try modelContext.save()
                    selectedPlaylist = playlist
                    Log.debug("Playlist saved successfully for \(title)")
                } catch {
                    Log.debug("Error saving playlist: \(error.localizedDescription)")
                }
            }
        } catch {
            Log.fault("API Error for \(title): \(error.localizedDescription)")
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
                .submitLabel(.search)
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
