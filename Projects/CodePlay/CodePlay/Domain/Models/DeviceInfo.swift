//
//  DeviceInfo.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/17/25.
//

import Foundation
import SwiftData

@Model
class DeviceInfo {
    @Attribute(.unique) var userId: UUID
    var deviceToken: String
    
    init(userId: UUID, deviceToken: String) {
        self.userId = userId
        self.deviceToken = deviceToken
    }
}
