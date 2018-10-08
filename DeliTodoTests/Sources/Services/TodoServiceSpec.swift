//
//  TodoServiceSpec.swift
//  DeliTodoTests
//
//  Created by Kawoou on 08/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Quick
import Nimble

import Deli
import RxBlocking
import RxSwift

@testable import DeliTodo

final class TodoServiceSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: TodoService!
        var mockTodoRepository: MockTodoRepository!
        var mockAuthService: MockAuthService!

        var disposeBag: DisposeBag!

        beforeEach {
            testModule.register(
                MockTodoRepository.self,
                resolver: { MockTodoRepository() },
                qualifier: "local",
                scope: .singleton
            ).link(TodoRepository.self)

            testModule.register(
                MockAuthService.self,
                resolver: { MockAuthService() },
                qualifier: "",
                scope: .singleton
            ).link(AuthService.self)

            mockTodoRepository = AppContext.shared.get(MockTodoRepository.self, qualifier: "local")
            mockAuthService = AppContext.shared.get(MockAuthService.self)
            sut = AppContext.shared.get(TodoService.self)

            disposeBag = DisposeBag()
        }
        describe("TodoService's") {
            context("before logged-in after logged-out") {
                beforeEach {
                    mockAuthService.expectedObserveUser.onNext(nil)
                    mockAuthService.expectedObserveUser.onNext(DummyUser.user)
                    mockAuthService.expectedObserveUser.onNext(nil)
                }
                it("should called TodoRepository.clear()") {
                    expect(mockTodoRepository.numberOfClearCalled).toEventually(equal(1))
                }
            }
            describe("get()") {
                context("when logged-in") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = DummyUser.user
                    }
                    context("when exist todo") {
                        let todo = DummyTodo.nonChecked
                        beforeEach {
                            mockTodoRepository.expectedGet = .just(DummyTodo.nonChecked)
                        }
                        it("result should equal to todo") {
                            expect { try sut.get(id: "id").toBlocking().single() } == todo
                        }
                    }
                    context("when not exist todo") {
                        beforeEach {
                            mockTodoRepository.expectedGet = .error(TodoRepositoryError.notFound)
                        }
                        it("result should throw notFound error") {
                            expect { try sut.get(id: "id").toBlocking().single() }
                                .to(throwError(TodoRepositoryError.notFound))
                        }
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.get(id: "id").toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }
            describe("gets()") {
                context("when logged-in") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = DummyUser.user
                    }
                    context("when exist todo") {
                        let todos = [DummyTodo.nonChecked, DummyTodo.checked]
                        beforeEach {
                            mockTodoRepository.expectedGets = .just(todos)
                        }
                        it("result should equal to todo list") {
                            expect { try sut.gets().toBlocking().single() } == todos
                        }
                    }
                    context("when not exist todo") {
                        context("case 1") {
                            beforeEach {
                                mockTodoRepository.expectedGets = .error(TodoRepositoryError.notFound)
                            }
                            it("result should throw notFound error") {
                                expect { try sut.gets().toBlocking().single() } == []
                            }
                        }
                        context("case 2") {
                            beforeEach {
                                mockTodoRepository.expectedGets = .just([])
                            }
                            it("result should throw notFound error") {
                                expect { try sut.gets().toBlocking().single() } == []
                            }
                        }
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.gets().toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }
            describe("observe()") {
                context("when logged-in") {
                    var todoList = [Todo?]()
                    var todoSubject: BehaviorSubject<Todo?>!

                    beforeEach {
                        todoList = []
                        todoSubject = BehaviorSubject(value: DummyTodo.nonChecked)

                        mockAuthService.expectedCurrentUser = DummyUser.user
                        mockTodoRepository.expectedObserve = todoSubject

                        sut.observe(id: "id")
                            .subscribe(onNext: { todoList.append($0) })
                            .disposed(by: disposeBag)
                    }
                    context("after change todo") {
                        beforeEach {
                            todoSubject.onNext(DummyTodo.checked)
                        }
                        it("result should equal to changing list") {
                            expect(todoList).toEventually(equal([DummyTodo.nonChecked, DummyTodo.checked]))
                        }
                    }
                    context("when delete todo") {
                        beforeEach {
                            todoSubject.onNext(nil)
                        }
                        it("result should equal to changing list") {
                            expect(todoList).toEventually(equal([DummyTodo.nonChecked, nil]))
                        }
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.observe(id: "id").toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }
            describe("observes()") {
                context("when logged-in") {
                    var todoList = [[Todo]]()
                    var todoListSubject: BehaviorSubject<[Todo]>!

                    beforeEach {
                        todoList = []
                        todoListSubject = BehaviorSubject(value: [DummyTodo.nonChecked])

                        mockAuthService.expectedCurrentUser = DummyUser.user
                        mockTodoRepository.expectedObserves = todoListSubject

                        sut.observes()
                            .subscribe(onNext: { todoList.append($0) })
                            .disposed(by: disposeBag)
                    }
                    context("when insert todo") {
                        beforeEach {
                            todoListSubject.onNext([DummyTodo.nonChecked, DummyTodo.checked])
                        }
                        it("result should equal to changing list") {
                            expect(todoList).toEventually(equal(
                                [
                                    [DummyTodo.nonChecked],
                                    [DummyTodo.nonChecked, DummyTodo.checked]
                                ]
                            ))
                        }
                    }
                    context("when delete todo") {
                        beforeEach {
                            todoListSubject.onNext([])
                        }
                        it("result should equal to changing list") {
                            expect(todoList).toEventually(equal(
                                [
                                    [DummyTodo.nonChecked],
                                    []
                                ]
                            ))
                        }
                    }
                    context("when update todo") {
                        beforeEach {
                            todoListSubject.onNext([DummyTodo.checked])
                        }
                        it("result should equal to changing list") {
                            expect(todoList).toEventually(equal(
                                [
                                    [DummyTodo.nonChecked],
                                    [DummyTodo.checked]
                                ]
                            ))
                        }
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.observes().toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }
            describe("insert()") {
                context("when logged-in") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = DummyUser.user

                        _ = try? sut.insert(title: "Title").toBlocking().single()
                    }
                    it("should called TodoRepository.insert()") {
                        expect(mockTodoRepository.isInsertCalled) == true
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.insert(title: "Title").toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }
            describe("update()") {
                context("when logged-in") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = DummyUser.user

                        _ = try? sut.update(todo: DummyTodo.checked).toBlocking().single()
                    }
                    it("should called TodoRepository.update()") {
                        expect(mockTodoRepository.isUpdateCalled) == true
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.update(todo: DummyTodo.checked).toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }
            describe("delete()") {
                context("when logged-in") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = DummyUser.user

                        _ = try? sut.delete(id: "id").toBlocking().single()
                    }
                    it("should called TodoRepository.delete()") {
                        expect(mockTodoRepository.isDeleteCalled) == true
                    }
                }
                context("when logged-out") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = nil
                    }
                    it("result should throw userNotFound error") {
                        expect { try sut.delete(id: "id").toBlocking().single() }
                            .to(throwError(TodoServiceError.userNotFound))
                    }
                }
            }

        }
    }
}
