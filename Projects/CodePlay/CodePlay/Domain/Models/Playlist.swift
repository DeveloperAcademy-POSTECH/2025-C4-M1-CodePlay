//  Playlist.swift
//  CodePlay
//
//  Created by 성현 on 7/19/25.
//

import SwiftData
import Foundation

@Model
final class Playlist {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \PlaylistEntry.playlist)
    var entries: [PlaylistEntry] = []
    var period: String?
    var cast: String?
    var festivalId: String?
    var place: String?

    init(id: UUID = UUID(), title: String, createdAt: Date = .now, period: String? = nil, cast: String? = nil, festivalId: String? = nil, place: String? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.period = period
        self.cast = cast
        self.festivalId = festivalId
        self.place = place
    }
    
    // Optional: Computed property to get artists from cast
    var artists: [String] {
        guard let cast = cast else { return [] }
        return cast.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var isEmpty: Bool {
        return title.isEmpty == nil
    }
}
