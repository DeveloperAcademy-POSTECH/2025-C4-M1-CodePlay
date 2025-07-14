//
//  FestivalLoadingView.swift
//  CodePlay
//
//  Created by 성현 on 7/14/25.
//

import SwiftUI

struct FestivalLoadingView: View {
    var rawText: RawText
    
    var body: some View {
        Text("This is Loading 1")
            .onAppear {
                print(rawText.text)
            }
    }
}
