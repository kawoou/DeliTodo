//
//  DummyUser.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

@testable import DeliTodo

struct DummyUser {
    static var user: User {
        return User(id: "id1", email: "user1@email.com", name: "User 1")
    }
}
