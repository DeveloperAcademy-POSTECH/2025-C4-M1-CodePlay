//
//  MainView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI

struct MainView: View {
    private let mainFactory: any MainFactory
    
    init(mainFactory: any MainFactory) {
        self.mainFactory = mainFactory
    }

    var body: some View {
        Group {
            mainFactory.mainPosterView()
                .wrapAnyView()
        }
    }
}
