//
//  FestivalBox.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/25/25.
//

import SwiftUI

struct FestivalBox: View {
    let title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.BsmRegular())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(height: 25)
        .background(Color.blue10)
        .cornerRadius(99)
    }
}
