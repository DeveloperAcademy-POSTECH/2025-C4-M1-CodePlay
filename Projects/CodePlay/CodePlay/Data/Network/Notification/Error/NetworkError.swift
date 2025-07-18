//
//  NetworkError.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/18/25.
//

enum NetworkError: Error {
    case httpError(statusCode: Int)
    case decodingFailed(Error)
}
