//
//  MockAnalyticsProvider.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Umbrella

@testable import DeliTodo

final class MockAnalyticsProvider: RuntimeProviderType {

    // MARK: - Expect

    var eventNameList: [String] = []
    var parameterList: [[String: Any]?] = []

    // MARK: - Protocol

    var className: String = "MockAnalyticsProvider"
    var selectorName: String = ""

    func log(_ eventName: String, parameters: [String : Any]?) {
        eventNameList.append(eventName)
        parameterList.append(parameters)
    }

    init() {}
}
