//
//  File.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation
import UIKit

protocol ScanPosterUseCase {
    func execute(with images: [UIImage]) async throws -> RawText
}

class DefaultScanPosterUseCase: ScanPosterUseCase {
    private let repository: ScanPosterRepository
    
    init(repository: ScanPosterRepository) {
        self.repository = repository
    }
    
    func execute(with images: [UIImage]) async throws -> RawText {
        return try await repository.execute(with: images)
    }
}
