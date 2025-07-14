//
//  MainRouter.swift
//  CodePlay
//
//  Created by 성현 on 7/14/25.
//

internal import Combine
import SwiftUI

final class MainRouter: ObservableObject {
    @Published var path: [MainRoute] = []

    func reset() {
        path = []
    }

    func navigate(to route: MainRoute) {
        path.append(route)
    }

    func replace(with route: MainRoute) {
        path = [route]
    }

    func navigateToLoading1(with rawText: RawText) {
        path.append(.loading1(rawText))
    }
}
