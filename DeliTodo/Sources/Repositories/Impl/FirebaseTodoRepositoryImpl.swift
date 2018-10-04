//
//  FirebaseTodoRepositoryImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import FirebaseDatabase
import RxSwift

final class FirebaseTodoRepositoryImpl: TodoRepository, Autowired {
    
    // MARK: - Deli
    
    var qualifier: String? = "remote"
    
    // MARK: - Private
    
    private let table: DatabaseReference

    private func convertTodo(id: String?) -> (DataSnapshot) throws -> Todo {
        return { snapshot in
            let id = id ?? snapshot.key

            guard let object = snapshot.value as? [String: Any] else {
                throw TodoRepositoryError.notFound
            }
            guard let title = object["title"] as? String else {
                throw TodoRepositoryError.notFound
            }
            guard let isChecked = object["isChecked"] as? NSNumber else {
                throw TodoRepositoryError.notFound
            }
            guard let createdAt = object["createdAt"] as? NSNumber else {
                throw TodoRepositoryError.notFound
            }
            guard let updatedAt = object["updatedAt"] as? NSNumber else {
                throw TodoRepositoryError.notFound
            }

            return Todo(
                id: id,
                title: title,
                isChecked: isChecked.boolValue,
                createdAt: Date(timeIntervalSince1970: createdAt.doubleValue),
                updatedAt: Date(timeIntervalSince1970: updatedAt.doubleValue)
            )
        }
    }
    
    // MARK: - Public
    
    func get(id: String, for user: User) -> Single<Todo> {
        return table.child("\(user.id)/\(id)").rx
            .observeSingleEvent(of: .value)
            .checkExist(throwError: TodoRepositoryError.notFound)
            .map(convertTodo(id: id))
    }
    func gets(for user: User) -> Single<[Todo]> {
        return table.child("\(user.id)").rx
            .observeSingleEvent(of: .value)
            .map { [weak self] snapshot in
                guard let ss = self else { return [] }
                guard snapshot.hasChildren() else { return [] }
                guard let list = snapshot.children.allObjects as? [DataSnapshot] else { return [] }
                return try list.map(ss.convertTodo(id: nil))
            }
    }

    func observe(id: String, for user: User) -> Observable<Todo?> {
        return table.child("\(user.id)/\(id)").rx
            .observe(of: .value)
            .map(convertTodo(id: id))
    }
    func observes(for user: User) -> Observable<[Todo]> {
        return table.child("\(user.id)").rx
            .observe(of: .value)
            .map { [weak self] snapshot in
                guard let ss = self else { return [] }
                guard let list = snapshot.children.allObjects as? [DataSnapshot] else { return [] }
                return try list.map(ss.convertTodo(id: nil))
            }
    }

    func insert(_ todo: Todo, for user: User) -> Single<String> {
        return .create { [weak self] observer in
            guard let ss = self else {
                observer(.error(CommonError.nilSelf))
                return Disposables.create()
            }
            let key = todo.id

            let dict = NSMutableDictionary()
            dict.setValue(todo.title, forKey: "title")
            dict.setValue(NSNumber(value: todo.isChecked), forKey: "isChecked")
            dict.setValue(NSNumber(value: todo.createdAt.timeIntervalSince1970), forKey: "createdAt")
            dict.setValue(NSNumber(value: todo.updatedAt.timeIntervalSince1970), forKey: "updatedAt")

            ss.table.child("\(user.id)/\(key)")
                .setValue(dict)

            observer(.success(key))
            return Disposables.create()
        }
    }
    func update(_ todo: Todo, for user: User) -> Single<Void> {
        return .create { [weak self] observer in
            guard let ss = self else {
                observer(.error(CommonError.nilSelf))
                return Disposables.create()
            }
            let dict = NSMutableDictionary()
            dict.setValue(todo.title, forKey: "title")
            dict.setValue(NSNumber(value: todo.isChecked), forKey: "isChecked")
            dict.setValue(NSNumber(value: todo.createdAt.timeIntervalSince1970), forKey: "createdAt")
            dict.setValue(NSNumber(value: todo.updatedAt.timeIntervalSince1970), forKey: "updatedAt")

            ss.table.child("\(user.id)/\(todo.id)")
                .setValue(dict)

            observer(.success(Void()))
            return Disposables.create()
        }
    }
    func delete(id: String, for user: User) -> Single<Void> {
        return .create { [weak self] observer in
            self?.table.child("\(user.id)/\(id)").removeValue()

            observer(.success(Void()))
            return Disposables.create()
        }
    }
    func clear(for user: User) -> Single<Void> {
        return .create { [weak self] observer in
            self?.table.child("\(user.id)").removeValue()

            observer(.success(Void()))
            return Disposables.create()
        }
    }
    
    // MARK: - Lifecycle
    
    required init(todo table: DatabaseReference) {
        self.table = table
    }
    
}
