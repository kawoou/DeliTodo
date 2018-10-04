//
//  TodoRepository.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Foundation

import RxSwift

enum TodoRepositoryError: Error {
    case notFound
    case failedToInsert
}

protocol TodoRepository {
    func get(id: String, for user: User) -> Single<Todo>
    func gets(for user: User) -> Single<[Todo]>

    func observe(id: String, for user: User) -> Observable<Todo?>
    func observes(for user: User) -> Observable<[Todo]>

    func insert(_ todo: Todo, for user: User) -> Single<String>
    func update(_ todo: Todo, for user: User) -> Single<Void>
    func delete(id: String, for user: User) -> Single<Void>
    func clear(for user: User) -> Single<Void>
}
