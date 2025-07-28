//
//  FestivalCheckView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

internal import Combine
import SwiftData
import SwiftUI

struct FestivalCheckView: View {
    @State private var isNavigate: Bool = false
    @State private var isNavigateToSearch: Bool = false
    @State private var apiResponse: PostFestInfoResponseDTO?
    @State private var suggestTitles: SuggestTitlesModel?
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
            Color.clear
                .backgroundWithBlur()
                .ignoresSafeArea()

            VStack {
                Spacer().frame(height: 56)

                Text("인식한 페스티벌 정보가 맞나요?")
                    .font(.HlgBold())
                    .foregroundColor(Color.neu900)

                Spacer().frame(height: 6)

                Text("아니오를 하면 수기로 입력하게 됩니다.")
                    .font(.BmdRegular())
                    .foregroundColor(Color.neu700)

                Spacer().frame(height: 36)

                if wrapper.isLoading {
                    // 1. 로딩 상태를 가장 먼저 체크
                    ProgressView("페스티벌 정보 로딩 중...")
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: Color.blue)
                        )
                        .font(.BmdRegular())
                        .foregroundColor(Color.neutral700)

                } else if let data = wrapper.festivalData
                {
                    // 2. 로딩이 끝났고 데이터가 있으면 카드 뷰 표시
                    ArtistCard(
                        imageUrl: "https://example.com/festival-poster.jpg",  // 하드코딩
                        date: data.period,
                        title: data.title,
                        subTitle: data.place
                    )
                } else {
                    // 3. 로딩이 끝났는데 데이터가 없으면 (오류 등)
                    Text("페스티벌 정보를 불러오지 못했습니다.\n다시 시도해주세요.")
                        .font(.BmdRegular())
                        .foregroundColor(Color.neu700)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                bottombutton
            }
            .padding(.bottom, 50)
            .onAppear {
                Task {
                    let success = await wrapper.festivalCheckViewModel
                        .loadFestivalInfo(from: rawText?.text ?? "")

                    if let first = wrapper.suggestTitles.first {
                        
                        self.suggestTitles = SuggestTitlesModel(titles: wrapper.suggestTitles)
                    }

                    print("loadFestivalInfo 완료: \(success)")
                    print(
                        "festivalData after load: \(String(describing: wrapper.festivalCheckViewModel.festivalData))"
                    )
                    print(
                        "isLoading after load: \(wrapper.festivalCheckViewModel.isLoading)"
                    )
                    print("[suggestTitles]:\(suggestTitles)")
                    print("[savedPlaylist]:\(savedPlaylist)")
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


                NavigationLink(
                    destination: suggestTitles != nil ? AnyView(FestivalSearchView(suggestTitles: suggestTitles!)) : AnyView(EmptyView()),
                    isActive: $isNavigateToSearch
                ) {
                    EmptyView()
                }
            

        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var bottombutton: some View {
        HStack(spacing: 16) {
            Button(
                action: {
                    self.isNavigateToSearch = true
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(Color.clear)
                            .frame(height: 60)
                            .shadow(
                                color: Color(
                                    red: 0,
                                    green: 0.65,
                                    blue: 1
                                ).opacity(0.16),
                                radius: 6,
                                x: 0,
                                y: 2
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .inset(by: 1)
                                    .stroke(
                                        Color(
                                            red: 0.91,
                                            green: 0.45,
                                            blue: 0.93
                                        ),
                                        lineWidth: 2
                                    )
                            )

                        Text("아니요")
                            .font(.BlgBold())
                            .foregroundColor(Color.blue)
                            .padding(.vertical, 18)
                            .zIndex(1)
                    }
                }
            )

            Button(
                action: {
                    savePlaylist()
                    if savedPlaylist != nil {
                        self.isNavigate = true
                    }
                },
                label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 999)
                            .fill(Color.clear)
                            .frame(height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .inset(by: 1)
                                    .fill(
                                        LinearGradient(
                                            stops: [
                                                Gradient.Stop(
                                                    color: Color(
                                                        red: 0.91,
                                                        green: 0.45,
                                                        blue: 0.93
                                                    ),
                                                    location: 0.00
                                                ),
                                                Gradient.Stop(
                                                    color: Color(
                                                        red: 0,
                                                        green: 0.65,
                                                        blue: 1
                                                    ),
                                                    location: 1.00
                                                ),
                                            ],
                                            startPoint: UnitPoint(
                                                x: 0,
                                                y: 0.5
                                            ),
                                            endPoint: UnitPoint(
                                                x: 1,
                                                y: 0.5
                                            )
                                        )
                                    )
                            )

                        Text("맞아요")
                            .foregroundColor(Color.white)
                            .font(.BlgBold())
                            .padding(.vertical, 18)
                            .zIndex(1)
                    }
                }
            )
        }
        .padding(.horizontal, 16)
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
