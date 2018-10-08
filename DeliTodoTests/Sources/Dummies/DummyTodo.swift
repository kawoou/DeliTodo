//
//  DummyTodo.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Foundation

@testable import DeliTodo

struct DummyTodo {
    static var nonChecked: Todo {
        return Todo(
            id: "id1",
            title: "Todo 1",
            isChecked: false,
            createdAt: Date(timeIntervalSince1970: 10000),
            updatedAt: Date(timeIntervalSince1970: 20000)
        )
    }
    static var checked: Todo {
        return Todo(
            id: "id2",
            title: "Todo 2",
            isChecked: true,
            createdAt: Date(timeIntervalSince1970: 20000),
            updatedAt: Date(timeIntervalSince1970: 30000)
        )
    }
}
