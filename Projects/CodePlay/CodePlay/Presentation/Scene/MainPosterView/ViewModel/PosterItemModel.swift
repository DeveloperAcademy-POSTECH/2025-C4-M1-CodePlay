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
    var text: String

    // 기본 initializer
    init(id: UUID = UUID(), imageURLs: [URL?] = [], image: UIImage? = nil, text: String) {
        self.id = id
        self.imageURLs = imageURLs
        self.image = image
        self.text = text
    }

    var currentImageURL: URL? {
        guard !imageURLs.isEmpty, currentImageIndex < imageURLs.count else { return nil }
        return imageURLs[currentImageIndex]
    }

    var isEmpty: Bool {
        return text.isEmpty && imageURLs.isEmpty && image == nil
    }

    mutating func update(image: UIImage) {
        self.image = image
    }

    mutating func nextImage() {
        guard !imageURLs.isEmpty else { return }
        currentImageIndex = (currentImageIndex + 1) % imageURLs.count
    }

    mutating func clear() {
        self.image = nil
        self.text = ""
        self.imageURLs = []
        self.currentImageIndex = 0
    }
}

extension PosterItemModel {
    init(rawText: RawText, imageURLs: [URL?], image: UIImage?) {
        self.id = rawText.id
        self.imageURLs = imageURLs
        self.image = image
        self.text = rawText.text
    }

    init(rawText: RawText, imageURL: URL?, image: UIImage?) {
        self.id = rawText.id
        self.imageURLs = [imageURL]
        self.image = image
        self.text = rawText.text
    }

    static var empty: PosterItemModel {
        PosterItemModel(id: UUID(), imageURLs: [], text: "")
    }
}
