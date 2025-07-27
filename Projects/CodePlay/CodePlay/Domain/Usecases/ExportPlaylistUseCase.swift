//
//  File.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation
import MusicKit

protocol ExportPlaylistUseCase {
    func preProcessRawText(_ rawText: RawText) -> [String]
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async throws -> [PlaylistEntry]
    func exportToAppleMusic(playlist: Playlist, entries: [PlaylistEntry]) async throws
    
    // MARK: - Song Caching
    /// PlaylistEntry와 함께 Song 객체도 캐싱하는 메서드
    /// - Parameters:
    ///   - rawText: 원본 텍스트
    ///   - artistMatches: 아티스트 매칭 결과
    ///   - musicPlayerUseCase: Song 캐싱을 위한 UseCase
    /// - Returns: PlaylistEntry 배열
    func searchTopSongsWithCaching(
        from rawText: RawText,
        artistMatches: [ArtistMatch],
        musicPlayerUseCase: MusicPlayerUseCase
    ) async throws -> [PlaylistEntry]
}

final class DefaultExportPlaylistUseCase: ExportPlaylistUseCase {
    private let repository: ExportPlaylistRepository

    init(repository: ExportPlaylistRepository) {
        self.repository = repository
    }

    func preProcessRawText(_ rawText: RawText) -> [String] {
        return repository.prepareArtistCandidates(from: rawText)
    }

    func searchArtists(from rawText: RawText) async -> [ArtistMatch] {
        return await repository.searchArtists(from: rawText)
    }

    func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async throws -> [PlaylistEntry] {
        let title = rawText.text.components(separatedBy: .newlines).first ?? "My Playlist"
        let entries = await repository.searchTopSongs(for: artistMatches)

        try await repository.savePlaylist(title: title, entries: entries)
        repository.clearTemporaryData()

        return entries
    }
    
    func exportToAppleMusic(playlist: Playlist, entries: [PlaylistEntry]) async throws {
        let trackIds = entries.map { $0.trackId }
        try await repository.exportPlaylistToAppleMusic(title: playlist.title, trackIds: trackIds)
    }
    
    // MARK: - Song Caching Implementation
    func searchTopSongsWithCaching(
        from rawText: RawText,
        artistMatches: [ArtistMatch],
        musicPlayerUseCase: MusicPlayerUseCase
    ) async throws -> [PlaylistEntry] {
        let title = rawText.text.components(separatedBy: .newlines).first ?? "My Playlist"
        
        // 1. 기존 방식으로 PlaylistEntry 생성
        let entries = await repository.searchTopSongs(for: artistMatches)
        
        // 2. 백그라운드에서 Song 객체들을 캐싱
        Task {
            await cacheSongsInBackground(entries: entries, musicPlayerUseCase: musicPlayerUseCase)
        }
        
        // 3. 플레이리스트 저장
        try await repository.savePlaylist(title: title, entries: entries)
        repository.clearTemporaryData()
        
        return entries
    }
    
    /// 백그라운드에서 Song 객체들을 캐싱하는 private 메서드 (병렬 처리)
    /// - Parameters:
    ///   - entries: 캐싱할 PlaylistEntry 배열
    ///   - musicPlayerUseCase: Song 캐싱을 위한 UseCase
    private func cacheSongsInBackground(
        entries: [PlaylistEntry],
        musicPlayerUseCase: MusicPlayerUseCase
    ) async {
        print("🔄 백그라운드 Song 캐싱 시작 (\(entries.count)곡) - Song 우선, 메모리 선택적")
        
        // 병렬 처리로 모든 Song 동시 캐싱
        await withTaskGroup(of: Void.self) { group in
            for (index, entry) in entries.enumerated() {
                group.addTask {
                    do {
                        // MusicKit으로 Song 객체 검색
                        let musicItemID = MusicItemID(entry.trackId)
                        let request = MusicCatalogResourceRequest<Song>(
                            matching: \.id,
                            equalTo: musicItemID
                        )
                        let response = try await request.response()
                        
                        if let song = response.items.first {
                            // 1차: Song 객체 캐싱 (필수 - 가장 안정적)
                            musicPlayerUseCase.cacheSong(song, for: entry.trackId)
                            print("✅ Song 캐싱 완료 (\(index + 1)/\(entries.count)): \(entry.trackTitle)")
                            
                            // 2차: 메모리 오디오 프리로드 (선택적 - Preview URL 있는 경우만)
                            if song.previewAssets?.first?.url != nil {
                                do {
                                    await musicPlayerUseCase.preloadSongToMemory(song, for: entry.trackId)
                                    print("🚀 메모리 캐싱도 완료: \(entry.trackTitle)")
                                } catch {
                                    print("⚠️ 메모리 캐싱 실패 (Song은 성공): \(entry.trackTitle)")
                                }
                            } else {
                                print("⚠️ Preview URL 없음 (Song은 캐싱됨): \(entry.trackTitle)")
                            }
                            
                        } else {
                            print("❌ Song 없음: \(entry.trackTitle)")
                        }
                    } catch {
                        print("❌ 캐싱 실패: \(entry.trackTitle) - \(error)")
                    }
                }
            }
        }
        
        print("🎉 백그라운드 Song 캐싱 완료! (메모리 캐싱은 선택적)")
    }
}

