//
//  MockTodoRepository.swift
//  DeliTodoTests
//
//  Created by Kawoou on 08/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxSwift

@testable import DeliTodo

final class MockTodoRepository: TodoRepository {

    // MARK: - Expect

    var expectedGet: Single<Todo> = .error(MockError.notImplementated)
    var expectedGets: Single<[Todo]> = .error(MockError.notImplementated)
    var expectedObserve: Observable<Todo?> = .error(MockError.notImplementated)
    var expectedObserves: Observable<[Todo]> = .error(MockError.notImplementated)
    var expectedInsert: Single<String> = .error(MockError.notImplementated)
    var expectedUpdate: Single<Void> = .error(MockError.notImplementated)
    var expectedDelete: Single<Void> = .error(MockError.notImplementated)
    var expectedClear: Single<Void> = .error(MockError.notImplementated)

    var isGetCalled: Bool = false
    var isGetsCalled: Bool = false
    var isObserveCalled: Bool = false
    var isObservesCalled: Bool = false
    var isInsertCalled: Bool = false
    var isUpdateCalled: Bool = false
    var isDeleteCalled: Bool = false
    var isClearCalled: Bool = false

    var numberOfGetCalled: Int = 0
    var numberOfGetsCalled: Int = 0
    var numberOfObserveCalled: Int = 0
    var numberOfObservesCalled: Int = 0
    var numberOfInsertCalled: Int = 0
    var numberOfUpdateCalled: Int = 0
    var numberOfDeleteCalled: Int = 0
    var numberOfClearCalled: Int = 0

    // MARK: - Protocol

    func get(id: String, for user: User) -> Single<Todo> {
        isGetCalled = true
        numberOfGetCalled += 1
        return expectedGet
    }
    func gets(for user: User) -> Single<[Todo]> {
        isGetsCalled = true
        numberOfGetsCalled += 1
        return expectedGets
    }

    func observe(id: String, for user: User) -> Observable<Todo?> {
        isObserveCalled = true
        numberOfObserveCalled += 1
        return expectedObserve
    }
    func observes(for user: User) -> Observable<[Todo]> {
        isObservesCalled = true
        numberOfObservesCalled += 1
        return expectedObserves
    }

    func insert(_ todo: Todo, for user: User) -> Single<String> {
        isInsertCalled = true
        numberOfInsertCalled += 1
        return expectedInsert
    }
    func update(_ todo: Todo, for user: User) -> Single<Void> {
        isUpdateCalled = true
        numberOfUpdateCalled += 1
        return expectedUpdate
    }
    func delete(id: String, for user: User) -> Single<Void> {
        isDeleteCalled = true
        numberOfDeleteCalled += 1
        return expectedDelete
    }
    func clear(for user: User) -> Single<Void> {
        isClearCalled = true
        numberOfClearCalled += 1
        return expectedClear
    }

}
