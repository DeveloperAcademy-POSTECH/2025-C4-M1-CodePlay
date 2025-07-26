//
//  FestivalCheckView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI
import SwiftData

struct FestivalCheckView: View {
    @State private var isNavigate: Bool = false
    @State private var isNavigateToSearch: Bool = false
    @State private var festivalData: DynamoDataItem?  // API 응답 저장 (dynamoData[0])
    @State private var apiResponse: PostFestInfoResponseDTO?
    @State private var suggestTitles: SuggestTitlesModel?
    @State private var isLoading: Bool = true  // 로딩 상태 추가
    @State private var savedPlaylist: Playlist?
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @Environment(\.modelContext) private var modelContext
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
                    .foregroundColor(Color.neutral900)

                Spacer().frame(height: 6)

                Text("아니오를 하면 수기로 입력하게 됩니다.")
                    .font(.BmdRegular())
                    .foregroundColor(Color.neutral700)

                Spacer().frame(height: 36)

                if let data = festivalData, !isLoading {
                    ArtistCard(
                        imageUrl: "https://example.com/festival-poster.jpg",  // 하드코딩
                        date: data.period,
                        title: data.title,
                        subTitle: data.place
                    )
                } else {
                    // 로딩 인디케이터
                    ProgressView("페스티벌 정보 로딩 중...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                        .font(.BmdRegular())
                        .foregroundColor(Color.neutral700)
                }

                Spacer()

                bottombutton
            }
            .padding(.bottom, 50)
            .onAppear {
                // 뷰 렌더링 시작 시 API 호출
                if let text = rawText?.text {
                    Task {
                        do {
                            let request = PostFestInfoTextRequestDTO(rawText: text)
                            let response = try await NetworkService.shared.festivalinfoService.postFestInfoText(model: request)
                            apiResponse = response
                            
                            // dynamoData[0] 추출 (안전하게 옵셔널 처리)
                            if let firstDynamo = response.dynamoData.first {
                                festivalData = firstDynamo
                            }
                            
                            // 디버깅 콘솔 출력 (옵션)
                            print("Loaded Festival Data: Title - \(festivalData?.title ?? "N/A"), Period - \(festivalData?.period ?? "N/A"), Place - \(festivalData?.place ?? "N/A")")
                        } catch {
                            print("API Error: \(error.localizedDescription)")
                            // 에러 처리: festivalData = nil 유지 또는 기본 값 설정
                        }
                        isLoading = false  // API 완료 후 로딩 종료
                    }
                } else {
                    print("RawText is nil or empty")
                    isLoading = false
                }
            }

            NavigationLink(
                destination: savedPlaylist != nil ? AnyView(SelectArtistView(playlist: savedPlaylist!)) : AnyView(EmptyView()),
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
                    if let response = apiResponse {
                        let titles = response.top5.map { $0.title }
                        suggestTitles = SuggestTitlesModel(titles: titles)
                        isNavigateToSearch = true
                    }
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
                        isNavigate = true
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
        guard let data = festivalData else {
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
