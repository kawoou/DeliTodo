//
//  MockTodoService.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxSwift

@testable import DeliTodo

final class MockTodoService: TodoService {

    // MARK: - Expect

    var expectedGet: Single<Todo> = .error(MockError.notImplementated)
    var expectedGets: Single<[Todo]> = .error(MockError.notImplementated)
    var expectedObserve: Observable<Todo?> = .error(MockError.notImplementated)
    var expectedObserves: Observable<[Todo]> = .error(MockError.notImplementated)
    var expectedInsert: Single<String> = .error(MockError.notImplementated)
    var expectedUpdate: Single<Void> = .error(MockError.notImplementated)
    var expectedDelete: Single<Void> = .error(MockError.notImplementated)

    var isGetCalled: Bool = false
    var isGetsCalled: Bool = false
    var isObserveCalled: Bool = false
    var isObservesCalled: Bool = false
    var isInsertCalled: Bool = false
    var isUpdateCalled: Bool = false
    var isDeleteCalled: Bool = false

    var numberOfGetCalled: Int = 0
    var numberOfGetsCalled: Int = 0
    var numberOfObserveCalled: Int = 0
    var numberOfObservesCalled: Int = 0
    var numberOfInsertCalled: Int = 0
    var numberOfUpdateCalled: Int = 0
    var numberOfDeleteCalled: Int = 0

    // MARK: - Protocol

    func get(id: String) -> Single<Todo> {
        isGetCalled = true
        numberOfGetCalled += 1
        return expectedGet
    }
    func gets() -> Single<[Todo]> {
        isGetsCalled = true
        numberOfGetsCalled += 1
        return expectedGets
    }

    func observe(id: String) -> Observable<Todo?> {
        isObserveCalled = true
        numberOfObserveCalled += 1
        return expectedObserve
    }
    func observes() -> Observable<[Todo]> {
        isObservesCalled = true
        numberOfObservesCalled += 1
        return expectedObserves
    }

    func insert(title: String) -> Single<String> {
        isInsertCalled = true
        numberOfInsertCalled += 1
        return expectedInsert
    }
    func update(todo: Todo) -> Single<Void> {
        isUpdateCalled = true
        numberOfUpdateCalled += 1
        return expectedUpdate
    }
    func delete(id: String) -> Single<Void> {
        isDeleteCalled = true
        numberOfDeleteCalled += 1
        return expectedDelete
    }
}

