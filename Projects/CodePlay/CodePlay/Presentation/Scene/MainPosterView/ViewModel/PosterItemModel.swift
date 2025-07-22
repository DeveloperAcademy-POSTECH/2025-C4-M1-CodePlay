//
//  PosterItemViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import Foundation
import UIKit

/// 뷰에 바인딩되는 데이터 모델 - 뷰에 표시될 수정가능한 모델 타입 구조
struct PosterItemModel: Equatable, Identifiable {
    let id: UUID
    var imageURL: URL?  // 서버에서 제공 혹은 applemusic에서 가져온 앨범 자켓 url
    var image: UIImage?  // SwiftUI에서 즉시 보여줄 때
    var title: String
    var subtitle: String
    var date: String
    var isEmpty: Bool {
        return title.isEmpty && subtitle.isEmpty && date.isEmpty
            && imageURL == nil && image == nil
    }

    mutating func update(image: UIImage) {
        self.image = image
    }

    mutating func updateFromInfo(_ info: FestivalInfo) {
        self.title = info.title
        self.subtitle = info.subtitle
        self.date = info.date
    }

    mutating func clear() {
        self.image = nil
        self.date = ""
        self.title = ""
        self.subtitle = ""
        self.imageURL = nil
    }
}

extension PosterItemModel {
    init(info: FestivalInfo, imageURL: URL?, image: UIImage?) {
        self.id = info.id
        self.imageURL = imageURL
        self.image = image
        self.title = info.title
        self.subtitle = info.subtitle
        self.date = info.date
    }

    static var empty: PosterItemModel {
        PosterItemModel(id: UUID(), title: "", subtitle: "", date: "")
    }

    /// 목데이터 추가
    static let mock: [PosterItemModel] = [
        PosterItemModel(
            id: UUID(),
            imageURL: URL(string: "https://picsum.photos/296/296?random=1"),
            image: nil,
            title: "2025 부산국제록페스티벌",
            subtitle: "86 Songs",
            date: "2025.09.26.(금) ~ 2025.09.28(일)"
        ),
        PosterItemModel(
            id: UUID(),
            imageURL: URL(string: "https://picsum.photos/296/296?random=2"),
            image: nil,
            title: "Ultra Korea 2025",
            subtitle: "124 Songs",
            date: "2025.06.14.(토) ~ 2025.06.15.(일)"
        ),
        PosterItemModel(
            id: UUID(),
            imageURL: URL(string: "https://picsum.photos/296/296?random=3"),
            image: nil,
            title: "서울재즈페스티벌 2025",
            subtitle: "67 Songs",
            date: "2025.05.23.(금) ~ 2025.05.25.(일)"
        )
    ]
}
