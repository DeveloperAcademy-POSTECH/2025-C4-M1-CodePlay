//
//  MainView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI

struct MainView<Factory: MainFactory>: View {
    private let mainFactory: Factory

    init(mainFactory: Factory) {
        self.mainFactory = mainFactory
    }

    var body: some View {
        Group {
            mainFactory.licenseCheckView()
        }
    }
}

