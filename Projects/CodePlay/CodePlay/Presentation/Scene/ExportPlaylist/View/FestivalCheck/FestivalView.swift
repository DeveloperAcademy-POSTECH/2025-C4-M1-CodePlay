//
//  FestivalView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/29/25.
//

internal import Combine
import SwiftData
import SwiftUI

struct FestivalView: View {
    @State private var isNavigate: Bool = false
    @State private var isNavigateToSearch: Bool = false
    @State private var apiResponse: PostFestInfoResponseDTO?
    @State private var suggestTitles: SuggestTitlesModel?
    @State private var isLoading: Bool = true
    @State private var savedPlaylist: Playlist?
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    let rawText: RawText?

    init(rawText: RawText?) {
        self.rawText = rawText
    }

    var body: some View {
        ZStack {
            Group {
                if wrapper.showNoResultView {
//                if wrapper.festivalData == nil && !wrapper.isLoading {
                    FestivalNoneView()
                } else  {
                    VStack {
                        if wrapper.isLoading {
                            // 1. 로딩 상태를 가장 먼저 체크
                            ProgressView("페스티벌 정보 로딩 중...")
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: Color.blue)
                                )
                                .font(.BmdRegular())
                                .foregroundColor(Color.neutral700)

                            Spacer()

                            bottombutton
                                .padding(.bottom, 50)

                        } else if let data = wrapper.festivalData {
                            // 2. 로딩이 끝났고 데이터가 있으면 카드 뷰 표시
                            VStack {
                                Spacer().frame(height: 8)

                                Text("인식한 페스티벌 정보가 맞나요?")
                                    .font(.HlgBold())
                                    .foregroundColor(Color.neu900)

                                Spacer().frame(height: 6)

                                Text("아니오를 선택하면 페스티벌을 검색합니다.")
                                    .font(.BmdRegular())
                                    .foregroundColor(Color.neu700)
                                    .lineSpacing(4)

                                Spacer().frame(height: 36)

                                VStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(data.title)
                                            .font(.HmdBold())
                                        
                                        Text(data.place)
                                            .font(.BsmRegular())
                                        
                                        Text(data.period)
                                            .font(.BsmRegular())
                                        
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 15)
                                    .liquidGlass(style: .list)
                                }
                                .padding(.horizontal, 36)

                                Spacer()

                                bottombutton
                                    .padding(.bottom, 50)
                            }
                            .frame(maxWidth: .infinity)
                            .navigationBarBackButtonHidden()
                        }
                    }
                    .onAppear {
                        Task {
                            let success = await wrapper.festivalCheckViewModel
                                .loadFestivalInfo(from: rawText?.text ?? "")

                            if let first = wrapper.suggestTitles.first {
                                self.suggestTitles = SuggestTitlesModel(
                                    titles: wrapper.suggestTitles
                                )
                            }
                        }
                    }
                }
            }
            NavigationLink(
                destination: savedPlaylist != nil
                    ? AnyView(SelectArtistView(playlist: savedPlaylist!))
                    : AnyView(EmptyView()),
                isActive: $isNavigate
            ) {
                EmptyView()
            }
            .hidden()

            if suggestTitles != nil {
                NavigationLink(
                    destination: FestivalSearchView(
                        suggestTitles: suggestTitles!
                    ),
                    isActive: $isNavigateToSearch
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .backgroundWithBlur()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        NavigationUtil.popToRootView()
                    },
                    label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.neu900)
                    }
                )
            }
        }
        .navigationBarBackButtonHidden()
        .edgesIgnoringSafeArea(.bottom)
    }

    @ViewBuilder
    private var bottombutton: some View {
        HStack(spacing: 16) {
            BottomButton(title: "아니요", kind: .line) {
                self.isNavigateToSearch = true
            }

            BottomButton(title: "맞아요", kind: .colorFill) {
                savePlaylist()
                if savedPlaylist != nil {
                    self.isNavigate = true
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private func savePlaylist() {
        guard let data = wrapper.festivalData else {
            print("No festival data to save")
            return
        }

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
            savedPlaylist = playlist
            print("Playlist saved successfully")
        } catch {
            print("Error saving playlist: \(error.localizedDescription)")
        }
    }
}
