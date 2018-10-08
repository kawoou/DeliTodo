//
//  TodoSyncServiceSpec.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Quick
import Nimble

import Deli
import RxBlocking
import RxSwift

@testable import DeliTodo

final class TodoSyncServiceSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: SyncService!
        var mockLocalTodoRepository: MockTodoRepository!
        var mockRemoteTodoRepository: MockTodoRepository!
        var mockAuthService: MockAuthService!

        beforeEach {
            testModule.register(
                MockTodoRepository.self,
                resolver: { MockTodoRepository() },
                qualifier: "local",
                scope: .singleton
            ).link(TodoRepository.self)

            testModule.register(
                MockTodoRepository.self,
                resolver: { MockTodoRepository() },
                qualifier: "remote",
                scope: .singleton
            ).link(TodoRepository.self)

            testModule.register(
                MockAuthService.self,
                resolver: { MockAuthService() },
                qualifier: "",
                scope: .singleton
            ).link(AuthService.self)
            
            mockLocalTodoRepository = AppContext.shared.get(MockTodoRepository.self, qualifier: "local")
            mockRemoteTodoRepository = AppContext.shared.get(MockTodoRepository.self, qualifier: "remote")
            mockAuthService = AppContext.shared.get(MockAuthService.self)
            sut = AppContext.shared.get(TodoSyncServiceImpl.self, qualifier: "todo")
        }
        describe("SyncService's") {
            beforeEach {
                mockLocalTodoRepository.expectedClear = .just(Void())
                mockRemoteTodoRepository.expectedClear = .just(Void())

                mockLocalTodoRepository.expectedInsert = .just("")
                mockRemoteTodoRepository.expectedInsert = .just("")

                mockLocalTodoRepository.expectedGets = .just([DummyTodo.checked])
                mockRemoteTodoRepository.expectedGets = .just([DummyTodo.nonChecked])
                mockLocalTodoRepository.expectedObserves = .just([DummyTodo.checked])
                mockRemoteTodoRepository.expectedObserves = .just([DummyTodo.nonChecked])
            }
            context("when logged-in") {
                beforeEach {
                    mockAuthService.expectedCurrentUser = DummyUser.user
                    mockAuthService.expectedObserveUser.onNext(DummyUser.user)
                }
                it("should called local TodoRepository.clear()") {
                    expect(mockLocalTodoRepository.numberOfClearCalled).toEventually(equal(1))
                }
                it("should called local TodoRepository.insert()") {
                    expect(mockLocalTodoRepository.numberOfInsertCalled).toEventually(equal(1))
                }
                it("should called local and remote TodoRepository.observes()") {
                    expect(mockLocalTodoRepository.numberOfObservesCalled).toEventually(equal(1))
                    expect(mockRemoteTodoRepository.numberOfObservesCalled).toEventually(equal(1))
                }
            }
        }
    }
}
