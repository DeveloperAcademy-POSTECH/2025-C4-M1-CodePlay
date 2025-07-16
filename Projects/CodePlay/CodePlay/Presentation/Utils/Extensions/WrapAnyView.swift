//
//  WrapAnyView.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import SwiftUI

public extension View {
    func wrapAnyView() -> AnyView {
        AnyView(self)
    }
}
