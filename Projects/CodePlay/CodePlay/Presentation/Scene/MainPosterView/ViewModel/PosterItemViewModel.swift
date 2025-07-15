//
//  PosterItemViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import Foundation
import UIKit

struct PosterItemViewModel: Equatable, Identifiable {
    let id: UUID
    var imageURL: URL?           // 서버에서 제공 혹은 applemusic에서 가져온 앨범 자켓 url
    var image: UIImage?          // SwiftUI에서 즉시 보여줄 때
    var title: String
    var subtitle: String
    var date: String
}

extension PosterItemViewModel {
    init(info: FestivalInfo, imageURL: URL?, image: UIImage?) {
        self.id = info.id
        self.imageURL = imageURL
        self.image = image
        self.title = info.title
        self.subtitle = info.subtitle
        self.date = info.date
    }
}
