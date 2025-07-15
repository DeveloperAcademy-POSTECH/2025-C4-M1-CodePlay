//
//  MainFactory.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

struct MainFactoryDependencies {
    let mainFactory: any MainFactory
}

protocol MainFactory {
    associatedtype SomeView: View
    func licenseCheckView() -> SomeView
}

final class DefaultMainFactory: MainFactory {
    
    init () {}
    
    public func licenseCheckView() -> some View {
        return LicenseCheckView()
    }
}
