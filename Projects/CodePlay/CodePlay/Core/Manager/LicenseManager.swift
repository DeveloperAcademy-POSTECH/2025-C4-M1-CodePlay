//
//  LicenseManager.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/21/25.
//

final class LicenseManager {
    static let shared = LicenseManager()

    private var musicWrapper: MusicViewModelWrapper?

    private init() {}

    func configure(with musicWrapper: MusicViewModelWrapper) {
        self.musicWrapper = musicWrapper
    }

    var isLicensed: Bool {
        musicWrapper?.canPlayMusic == true
    }
}
