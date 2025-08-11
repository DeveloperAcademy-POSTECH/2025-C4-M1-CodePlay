//
//  FestivalCheckViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/28/25.
//

internal import Combine
import Foundation

enum FestivalFetchState {
    case idle
    case loading
    case success(PostFestInfoResponseDTO)
    case noResult
    case error(String)
}

// MARK: - Input
protocol FestivalCheckViewModelInput {
    func loadFestivalInfo(from rawText: String) async
}

// MARK: - Output
protocol FestivalCheckViewModelOutput {
    var festivalData: Observable<DynamoDataItem?> { get }
    var suggestTitles: Observable<[String]> { get set }
    var isLoading: Observable<Bool> { get set }
    var errorMessage: String? { get }
    var shouldShowNoResultView: Bool { get set }
}

// MARK: - ViewModel
protocol FestivalCheckViewModel: FestivalCheckViewModelInput,
    FestivalCheckViewModelOutput,
    ObservableObject
{}

// MARK: - Implementation
final class DefaultFestivalCheckViewModel: FestivalCheckViewModel {
    @Published private(set) var festivalData = Observable<DynamoDataItem?>(nil)
    @Published var suggestTitles = Observable<[String]>([])
    @Published var isLoading = Observable<Bool>(true)
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var state: FestivalFetchState = .idle
    var shouldShowNoResultView: Bool = false

    private let fetchFestivalInfoUseCase: FetchFestivalInfoUseCase

    init(fetchFestivalInfoUseCase: FetchFestivalInfoUseCase) {
        self.fetchFestivalInfoUseCase = fetchFestivalInfoUseCase
    }

    func loadFestivalInfo(from rawText: String) async {
        isLoading.value = true
        shouldShowNoResultView = false
        defer { isLoading.value = false }

        do {
            Log.debug("[FestivalCheckViewModel] 🔄 fetchFestivalInfoUseCase 시작")
            let response = try await fetchFestivalInfoUseCase.execute(
                rawText: rawText
            )
            Log.debug("[FestivalCheckViewModel] ✅ API 응답 수신: \(response)")

            guard let first = response.dynamoData.first else {
                Log.debug("[FestivalCheckViewModel] ❗️dynamoData 비어 있음")
                self.state = .noResult
                return
            }

            self.festivalData.value = first
            self.suggestTitles.value = response.top5.map { $0.title }
            Log.debug("[FestivalCheckViewModel] ✅ festivalData 업데이트 완료")
        } catch {
            self.shouldShowNoResultView = true
            Task {
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    self.shouldShowNoResultView = false
                }
            self.state = .error("알 수 없는 오류가 발생했습니다.")
            self.errorMessage = error.localizedDescription
            Log.fault("[FestivalCheckViewModel] ❌ Festival Info Fetch 실패: \(error)")
        }
    }
}
