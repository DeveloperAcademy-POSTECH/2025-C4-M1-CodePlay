//
//  MoyaLoggerPlugin.swift
//  CodePlay
//
//  Created by 성현 on 7/24/25.
//

import Foundation
import Moya
import UIKit

// MoyaLoggerPlugin : 발생하는 모든 네트워크 작업을 콘솔에 기록해주기 위함

final class MoyaLoggerPlugin: PluginType {
    // Request를 보낼 때 호출
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            Log.debug("--> 유효하지 않은 요청")
            return
        }
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"
        var log = "----------------------------------------------------\n[\(method)] \(url)\n----------------------------------------------------\n"
        log.append("API: \(target)\n")
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("header: \(headers)\n")
        }
        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
            log.append("\(bodyString)\n")
        }
        log.append("------------------- END \(method) --------------------------")
        Log.debug(log)
    }
    
    // Response가 왔을 때 호출
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }
    
    // Network 통신이 성공했을 때 호출
    func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        
        var log = "------------------- 네트워크 통신 성공(isFromError: \(isFromError)) -------------------"
        log.append("\n[\(statusCode)] \(url)\n----------------------------------------------------\n")
        log.append("API: \(target)\n")
        response.response?.allHeaderFields.forEach {
            log.append("\($0): \($1)\n")
        }
        if let reString = String(bytes: response.data, encoding: String.Encoding.utf8) {
            log.append("\(reString)\n")
        }
        log.append("------------------- END HTTP (\(response.data.count)-byte body) -------------------")
        Log.debug(log)
    }
    
    // Network 통신이 실패했을 때 호출
    func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSuceed(response, target: target, isFromError: true)
            return
        }
        var log = "네트워크 오류"
        log.append("<-- \(error.errorCode) \(target)\n")
        log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
        log.append("<-- END HTTP")
        Log.debug(log)
        
        let alertViewController = UIAlertController(title: "네트워크 연결 실패", message: "네트워크 환경을 한번 더 확인해주세요.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
    }
}
