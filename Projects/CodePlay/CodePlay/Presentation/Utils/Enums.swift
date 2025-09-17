//
//  Enums.swift
//  CodePlay
//
//  Created by 신얀 on 9/17/25.
//

import Foundation

// MARK: - 진입점 여부 판단
enum PlaylistEntrySource {
    case main
    case export
}

// MARK: - 페스티벌 데이터 로딩 상태
enum FestivalFetchState {
    case idle
    case loading
    case success(PostFestInfoResponseDTO)
    case noResult
    case error(String)
}