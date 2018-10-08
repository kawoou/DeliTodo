//
//  DeliConfiguration.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Quick
import Nimble

import Deli

final class DeliConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Quick.Configuration) {
        configuration.beforeEach {
            testModule.unload()

            AppContext.shared.reset()
            AppContext.shared.load(testModule, priority: .high)
        }
        configuration.afterEach {
            AppContext.shared.unload(testModule)
        }
    }
}
