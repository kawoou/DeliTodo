//
//  TodoService.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxSwift

enum TodoServiceError: Error {
    case userNotFound
}

protocol TodoService {
    func get(id: String) -> Single<Todo>
    func gets() -> Single<[Todo]>

    func observe(id: String) -> Observable<Todo?>
    func observes() -> Observable<[Todo]>

    func insert(title: String) -> Single<String>
    func update(todo: Todo) -> Single<Void>
    func delete(id: String) -> Single<Void>
}
