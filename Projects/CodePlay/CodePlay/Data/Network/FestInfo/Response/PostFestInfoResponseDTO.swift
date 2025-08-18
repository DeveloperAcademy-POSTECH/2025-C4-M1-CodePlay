//
//  PostFestInfoResponseDTO.swift
//  CodePlay
//
//  Created by 성현 on 7/17/25.
//
import Foundation

// Top-level response DTO
struct PostFestInfoResponseDTO: Decodable {
    let query: String
    let processedQuery: String
    let top5: [Top5Item]
    let dynamoData: [DynamoDataItem]
}

// Top5 배열 아이템
struct Top5Item: Decodable {
    let rank: Int
    let id: String
    let title: String
    let searchableText: String
    let cast: String
    let artists: [String]
}

// dynamoData 배열 아이템
struct DynamoDataItem: Decodable {
    let time: String
    let period: String
    let cast: String
    let festivalId: String
    let place: String
    let title: String
}
