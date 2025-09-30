//
//  MoyaProvider.swift
//  CodePlay
//
//  Created by 성현 on 7/24/25.
//

import Foundation
import Moya
import _Concurrency

extension MoyaProvider {
    func request(_ target: Target) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case .success(let response):    // 성공
                    continuation.resume(returning: response)
                case .failure(let error):       // 실패
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func requestWithBackoff(_ target: Target,
                                maxRetries: Int = 3,
                                initialDelay: Double = 0.4) async throws -> Response {
            var attempt = 0
            var delay = initialDelay

            while true {
                let resp = try await self.request(target)
                let code = resp.statusCode

                if (200...299).contains(code) { return resp }

                if code == 429 || (500...599).contains(code) {
                    if attempt >= maxRetries { return resp }

                    let retryAfter = (resp.response?
                        .value(forHTTPHeaderField: "Retry-After"))
                        .flatMap { Double($0) }

                    let jitter = Double.random(in: 0...0.25)
                    let sleepSec = retryAfter ?? (delay + jitter)

                    // ⬇️ 충돌 회피: _Concurrency.Task.sleep 사용
                    try await _Concurrency.Task.sleep(nanoseconds: UInt64(sleepSec * 1_000_000_000))

                    attempt += 1
                    delay *= 2
                    continue
                }

                return resp
            }
        }
}

