//
//  FestivalInfo.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import Foundation

/// RawText를 필터링해서 저장할 모델
struct FestivalInfo: Identifiable {
    let id: UUID
    let date: String
    let title: String
    let subtitle: String
}
