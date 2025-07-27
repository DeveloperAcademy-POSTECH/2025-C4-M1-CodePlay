//
//  CachedSong.swift
//  CodePlay
//
//  Created by Assistant on 12/29/24.
//

import Foundation
import MusicKit

/// 캐싱된 노래 정보를 담는 모델
struct CachedSong {
    /// 트랙 ID
    let trackId: String
    /// MusicKit Song 객체 (캐싱된 경우에만 존재)
    let song: Song?
    /// 캐싱 완료 여부
    let isLoaded: Bool
    
    /// 캐싱 실패한 경우의 생성자
    /// - Parameter trackId: 트랙 ID
    /// - Returns: 로드되지 않은 CachedSong
    static func failed(trackId: String) -> CachedSong {
        return CachedSong(trackId: trackId, song: nil, isLoaded: false)
    }
    
    /// 캐싱 성공한 경우의 생성자
    /// - Parameters:
    ///   - trackId: 트랙 ID
    ///   - song: 캐싱된 Song 객체
    /// - Returns: 로드된 CachedSong
    static func loaded(trackId: String, song: Song) -> CachedSong {
        return CachedSong(trackId: trackId, song: song, isLoaded: true)
    }
} 