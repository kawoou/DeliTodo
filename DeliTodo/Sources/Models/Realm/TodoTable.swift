//
//  RealmTodo.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Foundation

import RealmSwift

class TodoTable: Object {
    
    // MARK: - Property
    
    @objc dynamic var id: String = ""
    @objc dynamic var title = ""
    @objc dynamic var isChecked = false
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
 
    // MARK: - Realm
    
    override class func primaryKey() -> String? {
        return "id"
    }
    override class func indexedProperties() -> [String] {
        return ["updatedAt"]
    }
}
extension Todo {
    init(_ table: TodoTable) {
        self.id = table.id
        self.title = table.title
        self.isChecked = table.isChecked
        self.createdAt = table.createdAt
        self.updatedAt = table.updatedAt
    }
}
extension TodoTable {
    convenience init(_ todo: Todo) {
        self.init()
        self.id = todo.id
        self.title = todo.title
        self.isChecked = todo.isChecked
        self.createdAt = todo.createdAt
        self.updatedAt = todo.updatedAt
    }
}
