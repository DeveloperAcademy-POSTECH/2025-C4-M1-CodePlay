//
//  ArtistSearchResponseDTO.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation

struct GetArtistsResponseDTO: Decodable {
    let results: Results?

    struct Results: Decodable {
        let artists: Artists?
    }

    struct Artists: Decodable {
        // 일부 케이스에서 data가 빠지거나 빈 배열일 수 있으니 Optional로
        let data: [ArtistDTO]?
    }
}

struct ArtistDTO: Decodable {
    let id: String
    let attributes: Attributes?

    struct Attributes: Decodable {
        // name도 일부 엣지 케이스에서 누락될 수 있음
        let name: String?
        let artwork: Artwork?
    }
}

// 전역 Artwork 이름 그대로 유지 (템플릿 문자열만 받음)
struct Artwork: Decodable {
    let url: String?
}
