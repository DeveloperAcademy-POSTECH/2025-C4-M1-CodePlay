//
//  MainRoute.swift
//  CodePlay
//
//  Created by 성현 on 7/14/25.
//

import Foundation

enum MainRoute: Hashable {
    case musicPermission
    case main
    case scanner
    case loading1(RawText)
    case playlistResult
    case loading2
}
