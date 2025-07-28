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
    var festivalData: Observable<DynamoDataItem?> { get }
    var suggestTitles: Observable<[String]> { get set }
    var isLoading: Observable<Bool> { get set }
    var errorMessage: String? { get }
}

// MARK: - ViewModel
protocol FestivalCheckViewModel: FestivalCheckViewModelInput,
    FestivalCheckViewModelOutput,
    ObservableObject
{}

// MARK: - Implementation
@MainActor
final class DefaultFestivalCheckViewModel: FestivalCheckViewModel {
    @Published private(set) var festivalData = Observable<DynamoDataItem?>(nil)
    @Published var suggestTitles = Observable<[String]>([])
    @Published var isLoading = Observable<Bool>(true)
    @Published private(set) var errorMessage: String? = nil

    private let fetchFestivalInfoUseCase: FetchFestivalInfoUseCase

    init(fetchFestivalInfoUseCase: FetchFestivalInfoUseCase) {
        self.fetchFestivalInfoUseCase = fetchFestivalInfoUseCase
    }
    
    func loadFestivalInfo(from rawText: String) async -> Bool {
        isLoading.value = true
        defer { isLoading.value = false }
        
        do {
            print("[FestivalCheckViewModel] 🔄 fetchFestivalInfoUseCase 시작")
            let response = try await fetchFestivalInfoUseCase.execute(rawText: rawText)
            print("[FestivalCheckViewModel] ✅ API 응답 수신: \(response)")

            guard let first = response.dynamoData.first else {
                print("[FestivalCheckViewModel] ❗️dynamoData 비어 있음")
                return false
            }

            self.festivalData.value = first
            self.suggestTitles.value = response.top5.map { $0.title }
            print("[FestivalCheckViewModel] ✅ festivalData 업데이트 완료")
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            print("[FestivalCheckViewModel] ❌ Festival Info Fetch 실패: \(error)")
            return false
        }
    }
}
