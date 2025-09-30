//
//  GetTopSongsResponseDTO.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation

struct GetTopSongsResponseDTO: Decodable { let data: [SongDTO] } // 기존의 Song로 하면 Duplicate나서 임시 조치하였습니닷. 이슈 해결 이후 다시 바꿔볼게유

struct SongDTO: Decodable {
    let id: String
    let attributes: Attributes?
    struct Attributes: Decodable {
        let name: String
        let albumName: String?
        let previews: [Preview]?
        let artwork: Artwork?
        struct Preview: Decodable { let url: URL }
    }
}


