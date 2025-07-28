//
//  FetchFestivalInfoUseCase.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/28/25.
//

// MARK: FetchFestivalInfoUseCase
protocol FetchFestivalInfoUseCase {
    func execute(rawText: String) async throws -> PostFestInfoResponseDTO
}

// MARK: DefaultFetchFestivalInfoUseCase
final class DefaultFetchFestivalInfoUseCase: FetchFestivalInfoUseCase {
    private let repository: FestivalRepository

    init(repository: FestivalRepository) {
        self.repository = repository
    }

    func execute(rawText: String) async throws -> PostFestInfoResponseDTO {
        try await repository.fetchFestivalInfo(from: rawText)
    }
}
