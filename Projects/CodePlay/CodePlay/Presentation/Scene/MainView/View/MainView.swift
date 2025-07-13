//
//  MainView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI
internal import Combine

struct MainView: View {
    @State private var isActive: Bool = false // sheet의 상태를 다루는 변수
    @State private var reconizedText = ""
    
    var body: some View {
        VStack {
            Button(action: {
                isActive = true
                reconizedText = ""
            }, label: {
                Text("페스티벌 라인업 인식")
            })
        }
        .sheet(isPresented: $isActive) {
            ScannerView(recognizedText: $reconizedText)
        }
    }
}

final class MainViewModelWrapper: ObservableObject {
    var objectWillChange: ObservableObjectPublisher?
    
    @Published var rawText: RawText?
    
    var viewModel: any MainViewModel
    
    init(viewModel: any MainViewModel) {
        self.viewModel = viewModel
    }
}

#Preview {
    MainView()
}
