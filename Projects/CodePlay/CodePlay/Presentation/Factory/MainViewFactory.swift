//
//  MainFactory.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

final class MainViewFactory {
    private let diContainer: MainSceneDIContainer

    init(diContainer: MainSceneDIContainer) {
        self.diContainer = diContainer
    }

    func makeMainView(router: MainRouter) -> some View {
        MainView {
            router.navigate(to: .scanner)
        }
    }

    func makeScannerView(router: MainRouter) -> some View {
        ScannerView { result in
            router.navigate(to: .loading1(result))
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            //                router.navigate(to: .playlistResult(result))
            //            }
        }
    }

    func makeFestivalLoadingView(router: MainRouter, rawText: RawText)
        -> some View {
        FestivalLoadingView(rawText: rawText)
    }

    // 기타 뷰들도 여기에 계속 추가 가능
}
