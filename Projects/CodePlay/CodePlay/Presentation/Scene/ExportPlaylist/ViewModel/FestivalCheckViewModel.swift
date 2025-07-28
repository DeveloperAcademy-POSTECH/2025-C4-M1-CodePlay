//
//  FestivalCheckViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/28/25.
//

internal import Combine
import Foundation

// MARK: - Input
protocol FestivalCheckViewModelInput {
    func loadFestivalInfo(from rawText: String) async -> Bool
}

// MARK: - Output
protocol FestivalCheckViewModelOutput {
    var festivalData: DynamoDataItem? { get }
    var suggestTitles: [String] { get }
    var isLoading: Bool { get set }
    var errorMessage: String? { get }
    var navigateToSelectArtist: Bool { get set }
    var navigateToFestivalSearch: Bool { get set }
}

// MARK: - ViewModel
protocol FestivalCheckViewModel: FestivalCheckViewModelInput,
    FestivalCheckViewModelOutput,
    ObservableObject
{}

// MARK: - Implementation
@MainActor
final class DefaultFestivalCheckViewModel: FestivalCheckViewModel {
    @Published private(set) var festivalData: DynamoDataItem?
    @Published private(set) var suggestTitles: [String] = []
    @Published var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published var navigateToSelectArtist: Bool = false
    @Published var navigateToFestivalSearch: Bool = false

    private let fetchFestivalInfoUseCase: FetchFestivalInfoUseCase

    init(fetchFestivalInfoUseCase: FetchFestivalInfoUseCase) {
        self.fetchFestivalInfoUseCase = fetchFestivalInfoUseCase
    }
    

    func loadFestivalInfo(from rawText: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("[FestivalCheckViewModel] 🔄 fetchFestivalInfoUseCase 시작")
            let response = try await fetchFestivalInfoUseCase.execute(rawText: rawText)
            print("[FestivalCheckViewModel] ✅ API 응답 수신: \(response)")

            guard let first = response.dynamoData.first else {
                print("[FestivalCheckViewModel] ❗️dynamoData 비어 있음")
                return false
            }

            self.festivalData = first
            self.suggestTitles = response.top5.map { $0.title }
            print("[FestivalCheckViewModel] ✅ festivalData 업데이트 완료")
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            print("[FestivalCheckViewModel] ❌ Festival Info Fetch 실패: \(error)")
            return false
        }
    }

}
