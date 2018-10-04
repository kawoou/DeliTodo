//
//  Todo.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Foundation

struct Todo {
    var id: String
    var title: String
    var isChecked: Bool
    var createdAt: Date
    var updatedAt: Date
}
extension Todo: Equatable {
    static func ==(lhs: Todo, rhs: Todo) -> Bool {
        guard lhs.id == rhs.id else { return false }
        guard lhs.title == rhs.title else { return false }
        guard lhs.isChecked == rhs.isChecked else { return false }
        guard Int64(lhs.createdAt.timeIntervalSince1970) == Int64(rhs.createdAt.timeIntervalSince1970) else { return false }
        guard Int64(lhs.updatedAt.timeIntervalSince1970) == Int64(rhs.updatedAt.timeIntervalSince1970) else { return false }
        return true
    }
}
