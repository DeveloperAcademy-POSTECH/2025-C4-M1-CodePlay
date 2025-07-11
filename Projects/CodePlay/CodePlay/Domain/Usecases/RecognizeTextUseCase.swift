//
//  RecognizeTextUseCase.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation
import UIKit

/// VisionKit을 통해 텍스트를 추출하는 Usecase
protocol RecognizeTextUseCase {
    func execute(with images: [UIImage]) async throws -> RawText
}
