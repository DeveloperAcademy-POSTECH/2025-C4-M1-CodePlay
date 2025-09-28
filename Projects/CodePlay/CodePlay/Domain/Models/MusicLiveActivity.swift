import ActivityKit
import Foundation

struct MusicLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        let trackTitle: String
        let artistName: String
        let albumArtworkURL: String?
        let progress: Double
        let isPlaying: Bool
        let remainingTime: TimeInterval
    }

    let trackId: String
}

typealias MusicLiveActivity = Activity<MusicLiveActivityAttributes>