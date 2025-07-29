//
//  FestivalRepository.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/28/25.
//

// MARK: FestivalRepository
protocol FestivalRepository {
    func fetchFestivalInfo(from rawText: String) async throws -> PostFestInfoResponseDTO
}

// MARK: DefaultFestivalRepository
final class DefaultFestivalRepository: FestivalRepository {
    func fetchFestivalInfo(from rawText: String) async throws -> PostFestInfoResponseDTO {
        let request = PostFestInfoTextRequestDTO(rawText: rawText)
        return try await NetworkService.shared.festivalinfoService.postFestInfoText(model: request)
    }
}
