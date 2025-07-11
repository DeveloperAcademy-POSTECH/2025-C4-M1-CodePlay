//
//  RawData.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation

struct RawText: Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date

    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
}
