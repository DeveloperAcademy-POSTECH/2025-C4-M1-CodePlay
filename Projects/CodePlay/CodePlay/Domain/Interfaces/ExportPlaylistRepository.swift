//
//  ExportPlaylistRepository.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import Foundation
import MusicKit
import SwiftData



// MARK: - ExportPlaylistRepository 프로토콜 (인터페이스)
// Apple Music 기반의 아티스트 탐색 및 플레이리스트 생성 기능을 담당하는 Repository 프로토콜
protocol ExportPlaylistRepository {
    func prepareArtistCandidates(from rawText: RawText) -> Set<String>
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry]
    func savePlaylist(title: String, entries: [PlaylistEntry]) async throws -> Playlist
    func clearTemporaryData()
    func exportPlaylistToAppleMusic(title: String, trackIds: [String]) async throws
}

// MARK: - DefaultExportPlaylistRepository 클래스 (구현체)
// 기본 구현체: OCR 텍스트 → 아티스트 후보 추출 → Apple Music에서 탐색 및 플레이리스트 생성
final class DefaultExportPlaylistRepository: ExportPlaylistRepository {
    private var temporaryMatches: [ArtistMatch] = [] // 임시 검색 결과 (메모리 캐시용)

    private let modelContext: ModelContext // SwiftData 모델 컨텍스트 (데이터 영구 저장을 위함)

    // 이니셜라이저 (객체 생성 시 호출됨)
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - 아티스트 후보 추출 로직 개선 (핵심 부분!)
    // OCR 텍스트에서 아티스트 후보 문자열을 생성 (Set으로 반환하여 자동 중복 제거)
    // 이 함수는 원본 OCR 텍스트(rawText)를 받아서, 아티스트 이름일 가능성이 있는 문자열들을 추출합니다.
    func prepareArtistCandidates(from rawText: RawText) -> Set<String> {
        // 1. OCR 텍스트를 줄(newline) 단위로 나눕니다.
        // `CharacterSet.newlines`는 모든 종류의 줄바꿈 문자(LF, CR, CRLF 등)를 포함하는 집합입니다.
        let lines = rawText.text.components(separatedBy: CharacterSet.newlines)
            // 2. 각 줄의 앞뒤 공백(띄어쓰기, 탭 등)을 제거합니다.
            // `CharacterSet.whitespacesAndNewlines`는 공백과 줄바꿈 문자를 포함하는 집합입니다.
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            // 3. 비어있는 줄은 제거합니다.
            .filter { !$0.isEmpty }

        var candidates: Set<String> = [] // 아티스트 이름 후보들을 저장할 Set (중복 자동 제거)
        var inArtistSection = false // "LINEUP:" 같은 키워드 이후에 아티스트 섹션으로 진입했는지 여부를 나타내는 플래그

        // 각 줄을 반복하면서 아티스트 후보를 찾습니다.
        for line in lines {
            let lowercasedLine = line.lowercased() // 현재 줄을 소문자로 변환하여 비교에 사용
            
            let lineupPattern = #"line[\s_-]?up"# // "line" 뒤에 공백, 하이픈, 언더스코어 중 0개 또는 1개(?)가 오고 "up"

            // if 문에서 정규 표현식으로 검사합니다.
            if lowercasedLine.range(of: lineupPattern, options: .regularExpression) != nil ||
               lowercasedLine.contains("artists") ||
               lowercasedLine.contains("featuring") {
                inArtistSection = true
                continue
            }
            
            // 1-2. 아티스트 섹션 종료 키워드 (선택 사항: 포스터 하단에 흔히 있는 정보)
            // 아티스트 섹션(`inArtistSection`이 true)일 때,
            // "tickets", "venue info", "presented by", "sponsored by", "and more" 같은
            // 아티스트 라인업이 끝났음을 암시하는 키워드가 나타나면 섹션 종료로 간주합니다.
            let artistSectionEndKeywords = [
                "tickets", "venue info", "presented by", "sponsored by", "and more",
                "buy now", "early bird", "pre-sale", "on sale", "official", "homepage",
                "follow us", "contact", "www", ".com", ".net", ".org", "instagram", "facebook",
                "twitter", "youtube", "tiktok", "spotify", "apple music",
                "produced by", "official music partners", "contact us", "info", "terms" // 추가
            ]
            if inArtistSection && artistSectionEndKeywords.contains(where: { lowercasedLine.contains($0) }) {
                inArtistSection = false
                continue
            }

            // 1-3. 일반적인 노이즈 또는 날짜/장소 필터링
            // 이 필터는 `inArtistSection` 여부와 관계없이 적용됩니다.
            // 아티스트 이름이 아닐 가능성이 높은 줄(예: 무의미한 OCR 오류, 날짜/장소 정보)을 걸러냅니다.
            if isGeneralNoise(lowercasedLine) || isDateOrLocation(lowercasedLine) {
                continue // 이 줄은 아티스트 이름이 아니므로 다음 줄로 넘어갑니다.
            }
            
            // --- 이 라인이 잠재적인 아티스트 라인이라고 판단되면 (위 필터를 모두 통과하면) ---
            // 2. 라인 내부에서 여러 아티스트 이름 분리 시도 (다양한 구분자 기반)
            // 콤마(,), 슬래시(/), 앰퍼샌드(&), 숫자 '1', 소문자 'l', 대문자 'I', 수직선 '|', 백슬래시 '\'를 구분자로 사용
            // `\`는 Swift에서 특수 문자(이스케이프 문자)이므로, 실제 백슬래시 문자 하나를 나타내려면 `\\`와 같이 두 개를 써야 합니다.
            let separators = CharacterSet(charactersIn: ",/&1lI|\\")
            let components = line.components(separatedBy: separators) // 줄을 구분자로 나눕니다.
                // flatMap은 중첩된 배열을 평탄화하고, 옵셔널 값을 제거하는 데 사용됩니다.
                // 여기서는 "feat."이나 "ft." 같은 키워드로 한 번 더 분리합니다.
                .flatMap { component -> [String] in
                    // "feat."으로 분리 시도 (대소문자 무시)
                    let featSeparated = component.components(separatedBy: "feat.")
                    // "ft."으로 분리 시도
                    let ftSeparated = featSeparated.flatMap { $0.components(separatedBy: "ft.") }
                    return ftSeparated
                }
                .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) } // 앞뒤 공백 제거
                .filter { !$0.isEmpty } // 빈 문자열 제거 (예: 구분자 바로 옆에 빈 공간이 생긴 경우)

            // 분리된 각 컴포넌트(potential artist name)를 처리합니다.
            for component in components {
                let cleanedComponent = cleanArtistNameForCandidate(component) // 아티스트 이름 클리닝 함수 호출
                if !cleanedComponent.isEmpty { // 클리닝 후에도 비어있지 않다면
                    candidates.insert(cleanedComponent) // Set에 추가 (Set은 중복을 자동으로 제거합니다!)
                }
            }
            
            // 3. N-gram (1~3단어 조합)을 사용하여 추가 후보 생성
            // 한 줄 내에서 1개, 2개, 3개의 단어를 조합하여 아티스트 이름을 만들고 후보에 추가합니다.
            // 예를 들어 "Imagine Dragons"는 "Imagine", "Dragons", "Imagine Dragons" 세 가지 후보를 만들 수 있습니다.
            let words = line.components(separatedBy: CharacterSet.whitespacesAndNewlines).filter { !$0.isEmpty }
            for i in 0..<words.count {
                // `Swift.min(3, words.count - i)`: 1개, 2개 또는 최대 3개 단어까지 조합하되,
                // 남은 단어의 개수를 넘지 않도록 합니다. `Swift.min`으로 전역 함수임을 명확히 합니다.
                for len in 1...Swift.min(3, words.count - i) {
                    let chunk = words[i..<i+len].joined(separator: " ") // 단어들을 공백으로 연결하여 하나의 덩어리(chunk)로 만듭니다.
                    let cleanedChunk = cleanArtistNameForCandidate(chunk) // 덩어리 클리닝
                    if !cleanedChunk.isEmpty {
                        candidates.insert(cleanedChunk) // Set에 추가
                    }
                }
            }
        }
        
        // 4. Fallback 로직: 'LINEUP:' 같은 아티스트 섹션 키워드를 찾지 못했거나
        // 위 로직에서 아티스트 후보가 하나도 추출되지 않은 경우에만 실행됩니다.
        // 모든 라인에 대해 더 광범위하게 필터링하여 후보를 재추출 시도합니다.
        // (이 로직은 'Lineup:' 키워드가 없는 포스터에서도 아티스트를 찾을 수 있도록 돕습니다.)
        if candidates.isEmpty {
            for line in lines {
                let lowercasedLine = line.lowercased()
                // 일반 노이즈, 날짜/장소 정보가 아니고, 길이가 2자 이상인 경우에만 후보로 고려
                // 너무 짧은 문자열은 의미 없는 단어일 가능성이 높습니다.
                if !isGeneralNoise(lowercasedLine) && !isDateOrLocation(lowercasedLine) && lowercasedLine.count > 2 {
                    let cleanedLine = cleanArtistNameForCandidate(line) // 전체 라인 클리닝
                    if !cleanedLine.isEmpty {
                        candidates.insert(cleanedLine) // Set에 추가
                    }
                }
            }
        }

        return candidates // 최종 아티스트 후보 Set 반환
    }

    // 아티스트 후보 이름에서 불필요한 정보 제거 (공통 함수)
    // 이 함수는 'prepareArtistCandidates'에서 추출된 각 아티스트 후보를 더 깔끔하게 다듬습니다.
    private func cleanArtistNameForCandidate(_ name: String) -> String {
        var cleaned = name
            // 'Zero Width Space' (`\u{200B}`)는 눈에 보이지 않는 공백 문자로, OCR이 가끔 인식하는 경우가 있습니다. 이를 제거합니다.
            .replacingOccurrences(of: "\u{200B}", with: "")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) // 앞뒤 공백 및 줄바꿈 문자 제거
        
        // 괄호 안의 내용 제거 (예: "(DJ Set)", "(LIVE)", "(Acoustic)")
        // `\\s*\\([^)]*\\)`는 정규 표현식으로, 괄호와 그 안의 모든 내용을 찾습니다.
        // `options: String.CompareOptions.regularExpression`은 이 문자열이 정규 표현식임을 Swift에 알려줍니다.
        cleaned = cleaned.replacingOccurrences(of: "\\s*\\([^)]*\\)", with: "", options: String.CompareOptions.regularExpression)
        
        // 특정 키워드 제거 (대소문자 무시)
        // 아티스트 이름 뒤에 자주 붙지만 실제 이름은 아닌 단어들을 제거합니다.
        let keywordsToRemove = [" LIVE", " DJ SET", " B2B", " FT.", " FEAT.", "PRESENTS", "X", "TRIO", "BAND", "CREW", "CLUB", "JAZZ"]
        for keyword in keywordsToRemove {
            // `options: [.caseInsensitive, .regularExpression]`는 대소문자를 무시하고 정규 표현식으로 찾으라는 의미입니다.
            cleaned = cleaned.replacingOccurrences(of: keyword, with: "", options: [.caseInsensitive, .regularExpression])
        }
        
        // 기타 특수문자 제거 (이름에 사용되지 않을 법한 것들)
        // `[^a-zA-Z0-9\\s&.-]`는 알파벳, 숫자, 공백, 앰퍼샌드(&), 점(.), 하이픈(-)을 제외한 모든 문자를 찾습니다.
        cleaned = cleaned.replacingOccurrences(of: "[^a-zA-Z0-9\\s&.-]", with: "", options: String.CompareOptions.regularExpression)

        return cleaned.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) // 최종적으로 앞뒤 공백 제거
    }

    // 일반적인 노이즈 (페스티벌 이름, 주최사, 웹사이트, 이상한 OCR 결과 등) 판단
    // 이 함수는 아티스트 이름이 아닐 가능성이 높은 줄을 걸러냅니다.
    private func isGeneralNoise(_ line: String) -> Bool {
        let lower = line.lowercased()
        let noisePhrases = [
            // 페스티벌 정보/장소 관련
            "tokyo marine stadium", "summer sonic", "main stage", // "main stage"는 여기서 노이즈로 처리 (아티스트 이름이 아님)
            "live nation", "olympic stadium", "tokyo station", "marine arena", "confirmed",
            "festival", "presents", "date", "venue", "tickets", "line up", "artists", "featuring",
            // 홍보/연락처 관련
            "coming soon", "and more", "full lineup", "more info", "available now",
            "buy now", "early bird", "pre-sale", "on sale", "official", "homepage",
            "follow us", "contact", "www", ".com", ".net", ".org", "instagram", "facebook",
            "twitter", "youtube", "tiktok", "spotify", "apple music",
            "presented by", "sponsored by", "produced by", "official music partners",
            // 프로젝트 자체 관련 (예시)
            "codeplay", "study",
            // OCR 오류로 보이는 무의미한 숫자/문자 조합
            "0j0", "0007g008", "씨", "0j0", "100", "0007", "g008" // 예시에서 보였던 의미 없는 문자열들을 명확히 추가
        ]
        // 노이즈 문구가 포함되어 있거나, 3자리 이상 연속된 숫자가 있는 경우 (아마도 오류)
        return noisePhrases.contains(where: { lower.contains($0) }) ||
               lower.range(of: #"\d{3,}"#, options: String.CompareOptions.regularExpression) != nil
    }
    
    // 날짜 또는 장소 패턴인지 확인
    // 이 함수는 날짜나 장소 정보로 보이는 줄을 걸러냅니다.
    private func isDateOrLocation(_ line: String) -> Bool {
        let lower = line.lowercased()
        // 년도, 날짜 (월 일), 요일 등을 포함하는 패턴
        let datePattern = #"\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*\s+\d{1,2}(?:,\s*\d{4})?\b|\d{1,2}[-./ ]\d{1,2}[-./ ]\d{2,4}|\d{4}|\b(?:mon|tue|wed|thu|fri|sat|sun)\w*\b"#
        // 장소 키워드
        let locationPattern = #"\b(?:stadium|arena|park|hall|venue|center|centre|dome)\b"#
        
        // 날짜 패턴, 장소 패턴, 시간 패턴(예: 10:00), 국가/도시명이 포함되어 있는지 확인합니다.
        return lower.range(of: datePattern, options: String.CompareOptions.regularExpression) != nil ||
               lower.range(of: locationPattern, options: String.CompareOptions.regularExpression) != nil ||
               lower.range(of: #"\d{1,2}:\d{2}"#, options: String.CompareOptions.regularExpression) != nil || // 시간 패턴 (예: 10:00)
               lower.contains("korea") || lower.contains("seoul") || lower.contains("japan") || // 국가/도시명 추가
               lower.contains("fri") || lower.contains("sat") || lower.contains("sun") // 요일도 추가
    }
    
    // MARK: - Apple Music 아티스트 검색 로직 (점수 기반 매칭 강화)
    // prepareArtistCandidates에서 얻은 후보들을 사용하여 Apple Music에서 실제 아티스트를 검색합니다.
    func searchArtists(from rawText: RawText) async -> [ArtistMatch] {
        let candidates = prepareArtistCandidates(from: rawText) // 개선된 후보 추출 함수 호출
        var uniqueArtistMatches: Set<ArtistMatch> = [] // Apple Music ID 기반으로 고유한 아티스트만 저장할 Set

        // 각 아티스트 이름 후보에 대해 반복합니다.
        for nameCandidate in candidates {
            // Apple Music에 보낼 검색어를 더 정제합니다.
            let cleanedSearchTerm = nameCandidate
                .lowercased() // 모두 소문자로 변환
                .replacingOccurrences(of: " ", with: "") // 공백 제거 (비교 시 용이)

            if cleanedSearchTerm.isEmpty { continue } // 검색어가 비어있으면 건너뜁니다.

            do {
                // MusicCatalogSearchRequest를 생성하여 Apple Music에 아티스트 검색 요청을 보냅니다.
                // `term`에 원본 `nameCandidate`를 사용해야 Apple Music이 더 넓은 범위에서 검색할 수 있습니다.
                var request = MusicCatalogSearchRequest(term: nameCandidate, types: [Artist.self])
                request.limit = 5 // 검색 결과를 최대 5개까지 가져와서 더 정교하게 필터링합니다.

                let response = try await request.response() // 비동기적으로 응답을 기다립니다.
                let matches = response.artists // 검색된 아티스트 목록

                var bestMatch: Artist? // 가장 적합한 아티스트
                var highestScore = 0.0 // 가장 높은 매칭 점수

                // 검색된 각 아티스트에 대해 점수를 매겨 가장 적합한 아티스트를 찾습니다.
                for artist in matches {
                    let artistNameLowercased = artist.name.lowercased()
                    var currentScore = 0.0 // 현재 아티스트의 매칭 점수

                    // 1. **정확히 일치하는 경우 (가장 높은 점수)**
                    if artistNameLowercased == nameCandidate.lowercased() {
                        currentScore += 100.0
                    }
                    // 2. **공백 제거 후 정확히 일치하는 경우**
                    else if artistNameLowercased.replacingOccurrences(of: " ", with: "") == cleanedSearchTerm {
                        currentScore += 90.0
                    }
                    // 3. **검색어(`nameCandidate`)가 아티스트 이름에 포함되는 경우** (예: "BTS" 검색 시 "BTS Official")
                    else if artistNameLowercased.contains(nameCandidate.lowercased()) {
                        currentScore += 70.0
                    }
                    // 4. **아티스트 이름이 검색어(`nameCandidate`)에 포함되는 경우** (예: "Coldplay" 검색 시 "Play")
                    // 이 경우는 오탐이 많을 수 있으므로 점수를 낮게 주거나 조건을 강화합니다.
                    else if nameCandidate.lowercased().contains(artistNameLowercased) {
                        // 아티스트 이름 길이가 검색어 길이의 절반 이상일 때만 점수 부여 (너무 짧은 단어 매칭 방지)
                        if artistNameLowercased.count >= nameCandidate.lowercased().count / 2 {
                             currentScore += 50.0
                        }
                    }
                    
                    // 5. **Levenshtein 거리 (편집 거리) 기반 유사성 점수 (오탈자, 약어 대응)**
                    // `levenshteinDistance` 함수는 두 문자열 간의 차이(편집 거리)를 계산합니다.
                    let distance = nameCandidate.lowercased().levenshteinDistance(to: artistNameLowercased)
                    // 거리가 길수록 문자열이 많이 다르다는 의미이므로, 거리를 정규화하여 비율로 점수를 계산합니다.
                    let normalizedDistance = Double(distance) / Double(Swift.max(nameCandidate.count, artistNameLowercased.count))
                    
                    // 정규화된 거리가 0.3 (30%) 미만일 때만 점수 부여 (너무 다른 문자열은 제외)
                    if normalizedDistance < 0.3 {
                        // 거리가 적을수록 높은 점수를 받도록 `(1.0 - normalizedDistance)`를 사용합니다.
                        currentScore += (1.0 - normalizedDistance) * 40.0
                    }

                    // 현재 아티스트의 점수가 지금까지의 최고 점수보다 높으면 업데이트합니다.
                    if currentScore > highestScore {
                        highestScore = currentScore
                        bestMatch = artist
                    }
                }
                
                // 최종적으로 선택된 아티스트가 있고, 점수가 일정 기준(60.0) 이상일 때만 유효한 매치로 간주합니다.
                if let artist = bestMatch, highestScore >= 60.0 {
                    let match = ArtistMatch(
                        rawText: rawText.text, // 원본 rawText.text 사용
                        artistName: artist.name,
                        appleMusicId: artist.id.rawValue,
                        profileArtworkUrl: artist.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
                        createdAt: .now
                    )
                    uniqueArtistMatches.insert(match) // Set에 삽입하여 Apple Music ID 기반 중복 자동 제거
                    print("✅ 매칭 아티스트: \(artist.name) (후보: \(nameCandidate), 점수: \(highestScore))")
                } else {
                    print("⚠️ 매칭 실패 또는 점수 미달: \(nameCandidate) (최고 점수: \(highestScore))")
                }
            } catch {
                print("❌ 검색 실패: \(nameCandidate) → \(error.localizedDescription)")
            }
        }
        
        temporaryMatches = Array(uniqueArtistMatches) // Set을 Array로 변환하여 임시 저장
        return temporaryMatches // Array로 반환
    }

    // MARK: - 각 아티스트에 대해 상위 3곡을 Apple Music에서 검색 후 PlaylistEntry로 변환
    // 이 함수는 아티스트들의 인기곡을 가져오는 로직을 담당합니다.
    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry] {
        var allEntries: [PlaylistEntry] = [] // 모든 플레이리스트 엔트리를 저장할 배열

        for artist in artists { // 각 아티스트에 대해 반복
            do {
                // 1. 아티스트 ID로 정확히 인기곡 검색 시도
                var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: MusicItemID(artist.appleMusicId))
                request.properties = [.topSongs] // `topSongs` 속성을 요청해야 인기곡 정보를 받을 수 있습니다.
                let response = try await request.response()
                
                guard let fullArtist = response.items.first else {
                    print("❌ 아티스트 정보 없음 (ID 검색 실패): \(artist.artistName)")
                    // ID로 검색 실패 시, 아티스트 이름으로 Song을 직접 검색하는 fallback 로직 수행
                    var fallbackSongRequest = MusicCatalogSearchRequest(term: artist.artistName, types: [Song.self])
                    fallbackSongRequest.limit = 5 // 여러 후보를 가져와서 필터링
                    let fallbackSongResponse = try await fallbackSongRequest.response()
                    let filteredSongs = fallbackSongResponse.songs.filter {
                        // 노래의 아티스트 이름이 검색어(`artist.artistName`)에 포함되거나 그 반대의 경우를 확인
                        $0.artistName.lowercased().contains(artist.artistName.lowercased()) ||
                        artist.artistName.lowercased().contains($0.artistName.lowercased())
                    }.prefix(3) // 상위 3곡만 선택
                    
                    // 필터링된 곡들로 PlaylistEntry 생성
                    for song in filteredSongs {
                         let entry = PlaylistEntry(
                            id: UUID(),
                            playlistId: UUID(), // 추후 save 시 덮어씌움
                            artistMatchId: artist.id, // ArtistMatch의 고유 ID
                            artistName: artist.artistName,
                            appleMusicId: artist.appleMusicId,
                            trackTitle: song.title,
                            trackId: song.id.rawValue,
                            trackPreviewUrl: song.previewAssets?.first?.url?.absoluteString ?? "",
                            profileArtworkUrl: artist.profileArtworkUrl,
                            albumArtworkUrl: song.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
                            createdAt: .now
                        )
                        allEntries.append(entry)
                    }
                    print("⚠️ \(artist.artistName)의 인기곡 fallback 결과: \(allEntries.filter { $0.artistMatchId == artist.id }.map { $0.trackTitle })")
                    continue // 다음 아티스트로 넘어감
                }

                // 2. 인기곡(`topSongs`)이 있는 경우
                if let topSongs = fullArtist.topSongs, !topSongs.isEmpty {
                    let limitedSongs = topSongs.prefix(3) // 상위 3곡만 선택
                    for song in limitedSongs {
                        let entry = PlaylistEntry(
                            id: UUID(),
                            playlistId: UUID(),
                            artistMatchId: artist.id,
                            artistName: artist.artistName,
                            appleMusicId: artist.appleMusicId,
                            trackTitle: song.title,
                            trackId: song.id.rawValue,
                            trackPreviewUrl: song.previewAssets?.first?.url?.absoluteString ?? "",
                            profileArtworkUrl: artist.profileArtworkUrl,
                            albumArtworkUrl: song.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
                            createdAt: .now
                        )
                        allEntries.append(entry)
                    }
                    print("🎶 \(artist.artistName)의 인기곡 (TopSongs): \(limitedSongs.map { $0.title })")
                } else {
                    // topSongs가 없는 경우, ID 검색 후에도 인기곡이 없으면 일반 검색 fallback 로직 사용
                    print("⚠️ \(artist.artistName)의 인기곡 없음, 일반 검색으로 대체 중…")
                    var fallbackSongRequest = MusicCatalogSearchRequest(term: artist.artistName, types: [Song.self])
                    fallbackSongRequest.limit = 5
                    let fallbackSongResponse = try await fallbackSongRequest.response()
                    let filteredSongs = fallbackSongResponse.songs.filter {
                        $0.artistName.lowercased().contains(artist.artistName.lowercased()) ||
                        artist.artistName.lowercased().contains($0.artistName.lowercased())
                    }.prefix(3)
                    
                    for song in filteredSongs {
                         let entry = PlaylistEntry(
                            id: UUID(),
                            playlistId: UUID(),
                            artistMatchId: artist.id,
                            artistName: artist.artistName,
                            appleMusicId: artist.appleMusicId,
                            trackTitle: song.title,
                            trackId: song.id.rawValue,
                            trackPreviewUrl: song.previewAssets?.first?.url?.absoluteString ?? "",
                            profileArtworkUrl: artist.profileArtworkUrl,
                            albumArtworkUrl: song.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
                            createdAt: .now
                        )
                        allEntries.append(entry)
                    }
                    print("🔍 \(artist.artistName)의 인기곡 fallback 결과: \(allEntries.filter { $0.artistMatchId == artist.id }.map { $0.trackTitle })")
                }
            } catch {
                print("❌ \(artist.artistName) 인기곡 검색 실패: \(error.localizedDescription)")
            }
        }
        return allEntries
    }

    // MARK: - SwiftData에 플레이리스트 저장 (영구 저장소)
    // `@MainActor`는 이 함수가 메인 스레드에서 실행되어야 함을 나타냅니다.
    // SwiftData와 SwiftUI의 UI 업데이트는 주로 메인 스레드에서 이루어지기 때문입니다.
    @MainActor
    func savePlaylist(title: String, entries: [PlaylistEntry]) async throws -> Playlist {
        let playlistId = UUID() // 새로운 플레이리스트의 고유 ID 생성
        let playlist = Playlist(id: playlistId, title: title, createdAt: .now) // 플레이리스트 객체 생성

        // 각 플레이리스트 엔트리(노래)에 생성된 플레이리스트 ID를 연결합니다.
        for entry in entries {
            entry.playlistId = playlistId
        }

        modelContext.insert(playlist) // SwiftData 컨텍스트에 플레이리스트 삽입
        for entry in entries {
            modelContext.insert(entry) // 각 엔트리 삽입
        }

        do {
            try modelContext.save() // 변경사항을 영구 저장소에 저장
            print("✅ Playlist saved to SwiftData: \(playlist.title)")
        } catch {
            print("❌ SwiftData save failed: \(error.localizedDescription)")
            throw error // 저장 실패 시 에러를 다시 던져 상위 호출자에게 알립니다.
        }
        return playlist
    }

    // MARK: - 임시 검색 결과 초기화
    // `temporaryMatches` 배열을 비워서 메모리를 정리합니다.
    func clearTemporaryData() {
        temporaryMatches = []
        print("🗑️ Temporary matches cleared.")
    }

    // MARK: - Apple Music 계정에 플레이리스트 생성 및 곡 추가
    // 사용자의 Apple Music 라이브러리에 실제 플레이리스트를 생성하는 기능입니다.
    func exportPlaylistToAppleMusic(title: String, trackIds: [String]) async throws {
        // `trackIds` (문자열 배열)를 `MusicItemID` (MusicKit의 고유 ID 타입) 배열로 변환합니다.
        let musicItemIDs = trackIds.map { MusicItemID($0) }

        // MusicKit을 사용하여 MusicItemID에 해당하는 곡 정보를 조회합니다.
        // `MusicLibrary.shared.createPlaylist`는 MusicItemID 컬렉션을 바로 받을 수 있으므로,
        // 이 조회 과정은 필수는 아니지만, 곡 ID의 유효성을 검사하는 차원에서 유지할 수 있습니다.
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, memberOf: musicItemIDs)
        let response = try await request.response()
        let songs = response.items // 조회된 곡 목록

        // 곡이 하나도 조회되지 않았다면 에러를 발생시킵니다.
        guard !songs.isEmpty else {
            throw NSError(
                domain: "ExportPlaylistError",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Apple Music에서 곡 정보를 찾을 수 없습니다. (ID 기반)"]
            )
        }

        // 조회된 곡들을 `MusicItemCollection`으로 묶습니다.
        let songCollection = MusicItemCollection(songs)

        // Apple Music 라이브러리에 새 플레이리스트를 생성합니다.
        let createdPlaylist = try await MusicLibrary.shared.createPlaylist(
            name: title, // 플레이리스트 제목
            description: "CodePlay OCR 기반 자동 생성", // 플레이리스트 설명
            items: songCollection // 추가할 곡들
        )

        print("✅ Apple Music playlist created: \(createdPlaylist.name), ID: \(createdPlaylist.id.rawValue)")
    }
}

// MARK: - String Extension for Levenshtein Distance
// 이 확장 기능은 `DefaultExportPlaylistRepository.swift` 파일의 가장 하단이나
// 별도의 파일 (예: `Extensions/String+Levenshtein.swift`)에 추가해주세요.
// `String` 타입에 `levenshteinDistance`라는 새로운 메서드를 추가하는 것입니다.
extension String {
    // `levenshteinDistance` 메서드는 현재 문자열과 목표 문자열 간의 편집 거리(유사성)를 계산합니다.
    // 편집 거리는 한 문자열을 다른 문자열로 변환하는 데 필요한 최소 단일 문자 편집(삽입, 삭제, 교체) 횟수입니다.
    func levenshteinDistance(to target: String) -> Int {
        let source = Array(self) // 현재 문자열을 문자 배열로 변환
        let target = Array(target) // 목표 문자열을 문자 배열로 변환

        let m = source.count // 원본 문자열 길이
        let n = target.count // 목표 문자열 길이
        // DP(Dynamic Programming) 테이블 초기화: dp[i][j]는 source의 i번째까지와 target의 j번째까지의 편집 거리를 저장합니다.
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        // 첫 번째 행과 열 초기화: 한 문자열이 비어있을 때의 편집 거리는 다른 문자열의 길이와 같습니다.
        for i in 0...m {
            dp[i][0] = i
        }

        for j in 0...n {
            dp[0][j] = j
        }

        // DP 테이블 채우기
        for i in 1...m {
            for j in 1...n {
                // 문자가 같으면 비용 0, 다르면 비용 1 (교체 비용)
                let cost = (source[i - 1] == target[j - 1]) ? 0 : 1
                // 3가지 경우 중 최솟값 선택:
                // 1. source에서 문자 삭제 (dp[i-1][j] + 1)
                // 2. target에 문자 삽입 (dp[i][j-1] + 1)
                // 3. source의 문자를 target의 문자로 교체 (dp[i-1][j-1] + cost)
                dp[i][j] = Swift.min(dp[i - 1][j] + 1,      // Deletion
                                   dp[i][j - 1] + 1,      // Insertion
                                   dp[i - 1][j - 1] + cost) // Substitution
            }
        }
        return dp[m][n] // 최종 편집 거리 반환
    }
}
