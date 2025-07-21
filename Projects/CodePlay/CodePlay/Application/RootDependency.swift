//
//  RootDependency.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import SwiftUI

// MARK: RootDependency
protocol RootDependency {
    var mainFactory: any MainFactory { get }
    var licenseFactory: any LicenseFactory { get }

}

final class RootComponent {
    private let dependency: RootDependency
    
    init(dependency: RootDependency) {
        self.dependency = dependency
    }
    
    func makeView() -> some View {
        MainView(mainFactory: dependency.mainFactory, licenseFactory: dependency.licenseFactory)
    }
}
