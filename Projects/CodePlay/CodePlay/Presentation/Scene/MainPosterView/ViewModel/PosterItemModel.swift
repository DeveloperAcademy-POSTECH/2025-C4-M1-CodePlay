//
//  PosterItemViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import Foundation
import UIKit

struct PosterItemModel: Equatable, Identifiable {
    let id: UUID
    var imageURLs: [URL?]
    var currentImageIndex: Int = 0
    var image: UIImage?
    var title: String
    var subtitle: String
    var date: String

    // 기본 initializer
    init(id: UUID = UUID(), imageURLs: [URL?] = [], image: UIImage? = nil, title: String, subtitle: String, date: String) {
        self.id = id
        self.imageURLs = imageURLs
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.date = date
    }

    var currentImageURL: URL? {
        guard !imageURLs.isEmpty, currentImageIndex < imageURLs.count else { return nil }
        return imageURLs[currentImageIndex]
    }

    var isEmpty: Bool {
        return title.isEmpty && subtitle.isEmpty && date.isEmpty
        && imageURLs.isEmpty && image == nil
    }

    mutating func update(image: UIImage) {
        self.image = image
    }

    mutating func updateFromInfo(_ info: FestivalInfo) {
        self.title = info.title
        self.subtitle = info.subtitle
        self.date = info.date
    }

    mutating func nextImage() {
        guard !imageURLs.isEmpty else { return }
        currentImageIndex = (currentImageIndex + 1) % imageURLs.count
    }

    mutating func clear() {
        self.image = nil
        self.date = ""
        self.title = ""
        self.subtitle = ""
        self.imageURLs = []
        self.currentImageIndex = 0
    }
}

extension PosterItemModel {
    init(info: FestivalInfo, imageURLs: [URL?], image: UIImage?) {
        self.id = info.id
        self.imageURLs = imageURLs
        self.image = image
        self.title = info.title
        self.subtitle = info.subtitle
        self.date = info.date
    }

    init(info: FestivalInfo, imageURL: URL?, image: UIImage?) {
        self.id = info.id
        self.imageURLs = [imageURL]
        self.image = image
        self.title = info.title
        self.subtitle = info.subtitle
        self.date = info.date
    }

    static var empty: PosterItemModel {
        PosterItemModel(id: UUID(), imageURLs: [], title: "", subtitle: "", date: "")
    }

    /// 목데이터 추가
    static let mock: [PosterItemModel] = [
        PosterItemModel(
            id: UUID(),
            imageURLs: [
                URL(string: "ArtistImg"),
                URL(string: "ArtistImg2"),
                URL(string: "ArtistImg3"),
                URL(string: "ArtistImg")
            ],
            image: nil,
            title: "2025 부산국제록페스티벌",
            subtitle: "86 Songs",
            date: "2025.09.26.(금) ~ 2025.09.28(일)"
        ),
        PosterItemModel(
            id: UUID(),
            imageURLs: [
                URL(string: "ArtistImg"),
                URL(string: "ArtistImg3"),
                URL(string: "ArtistImg"),
                URL(string: "ArtistImg2")
            ],
            image: nil,
            title: "Ultra Korea 2025",
            subtitle: "124 Songs",
            date: "2025.06.14.(토) ~ 2025.06.15.(일)"
        ),
        PosterItemModel(
            id: UUID(),
            imageURLs: [
                URL(string: "ArtistImg"),
                URL(string: "ArtistImg3"),
                URL(string: "ArtistImg2"),
                URL(string: "ArtistImg3"),
                URL(string: "ArtistImg")
            ],
            image: nil,
            title: "서울재즈페스티벌 2025",
            subtitle: "67 Songs",
            date: "2025.05.23.(금) ~ 2025.05.25.(일)"
        )
    ]
}
