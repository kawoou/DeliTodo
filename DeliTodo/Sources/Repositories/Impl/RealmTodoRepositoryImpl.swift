//
//  RealmTodoRepositoryImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import RealmSwift
import RxSwift

final class RealmTodoRepositoryImpl: TodoRepository, Autowired {
    
    // MARK: - Deli
    
    var qualifier: String? = "local"
    var scheduler: SchedulerType
    
    // MARK: - Private
    
    private let realm: Realm
    
    // MARK: - Public
    
    func get(id: String, for user: User) -> Single<Todo> {
        return realm.rx.object(of: TodoTable.self, forPrimaryKey: id)
            .map { todo in
                guard let todo = todo else { throw TodoRepositoryError.notFound }
                return Todo(todo)
            }
    }
    func gets(for user: User) -> Single<[Todo]> {
        return realm.rx.objects(of: TodoTable.self)
            .map { $0.map { Todo($0) } }
    }

    func observe(id: String, for user: User) -> Observable<Todo?> {
        return realm.rx.observe(of: TodoTable.self, forPrimaryKey: id)
            .map { todo in
                guard let todo = todo else { return nil }
                return Todo(todo)
            }
    }
    func observes(for user: User) -> Observable<[Todo]> {
        return realm.rx.observes(of: TodoTable.self)
            .map { $0.map { Todo($0) } }
    }

    func insert(_ todo: Todo, for user: User) -> Single<String> {
        return Single
            .create { [weak self] observer in
                guard let ss = self else {
                    observer(.error(CommonError.nilSelf))
                    return Disposables.create()
                }
                do {
                    ss.realm.beginWrite()
                    ss.realm.add(TodoTable(todo))
                    try ss.realm.commitWrite()

                    observer(.success(todo.title))
                } catch let error {
                    observer(.error(error))
                }
                return Disposables.create()
            }
            .subscribeOn(scheduler)
    }
    func update(_ todo: Todo, for user: User) -> Single<Void> {
        return Single
            .create { [weak self] observer in
                guard let ss = self else {
                    observer(.error(CommonError.nilSelf))
                    return Disposables.create()
                }
                do {
                    ss.realm.beginWrite()
                    ss.realm.add(TodoTable(todo), update: true)
                    try ss.realm.commitWrite()

                    observer(.success(Void()))
                } catch let error {
                    observer(.error(error))
                }
                return Disposables.create()
            }
            .subscribeOn(scheduler)
    }
    func delete(id: String, for user: User) -> Single<Void> {
        return realm.rx.object(of: TodoTable.self, forPrimaryKey: id)
            .flatMap { [weak self] todo -> Single<Void> in
                guard let ss = self else { throw CommonError.nilSelf }
                guard let todo = todo else { throw TodoRepositoryError.notFound }
                
                do {
                    ss.realm.beginWrite()
                    ss.realm.delete(todo)
                    try ss.realm.commitWrite()

                    return .just(Void())
                } catch let error {
                    throw error
                }
            }
            .subscribeOn(scheduler)
    }
    func clear(for user: User) -> Single<Void> {
        return realm.rx.objects(of: TodoTable.self)
            .flatMap { [weak self] list -> Single<Void> in
                guard let ss = self else { throw CommonError.nilSelf }

                do {
                    ss.realm.beginWrite()
                    ss.realm.delete(list)
                    try ss.realm.commitWrite()

                    return .just(Void())
                } catch let error {
                    throw error
                }
            }
            .subscribeOn(scheduler)
    }
    
    // MARK: - Lifecycle
    
    required init(_ realm: Realm, realm scheduler: SchedulerType) {
        self.realm = realm
        self.scheduler = scheduler
    }
}
