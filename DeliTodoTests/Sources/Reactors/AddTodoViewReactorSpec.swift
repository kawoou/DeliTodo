//
//  AddTodoViewReactorSpec.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Quick
import Nimble

import Deli
import RxSwift

@testable import DeliTodo

final class AddTodoViewReactorSpec: QuickSpec {
    override func spec() {
        super.spec()

        var mockToastService: MockToastService!
        var mockTodoService: MockTodoService!
        var sut: AddTodoViewReactor!

        beforeEach {
            testModule.register(
                MockTodoService.self,
                resolver: { MockTodoService() },
                qualifier: "",
                scope: .singleton
            ).link(TodoService.self)

            testModule.register(
                MockToastService.self,
                resolver: { MockToastService() },
                qualifier: "",
                scope: .singleton
            ).link(ToastService.self)

            mockToastService = AppContext.shared.get(MockToastService.self)
            mockTodoService = AppContext.shared.get(MockTodoService.self)
            sut = AppContext.shared.get(AddTodoViewReactor.self)
        }
        describe("AddTodoViewReactor's") {
            context("when set allow title") {
                beforeEach {
                    sut.action.onNext(.setTitle("Title"))
                }
                it("state.title should equal to 'Title'") {
                    expect(sut.currentState.title).toEventually(equal("Title"))
                }
                context("after called Action.create") {
                    context("success test") {
                        beforeEach {
                            mockTodoService.expectedInsert = .just("Title")
                            sut.action.onNext(.create)
                        }
                        it("state.isCreated should be true") {
                            expect(sut.currentState.isCreated).toEventually(beTrue())
                        }
                    }
                    context("failed test") {
                        beforeEach {
                            mockTodoService.expectedInsert = .error(TodoRepositoryError.notFound)
                            sut.action.onNext(.create)
                        }
                        it("should showed toast") {
                            expect(mockToastService.isShowCalled).toEventually(beTrue())
                        }
                    }
                }
            }
            context("when set denied title") {
                beforeEach {
                    sut.action.onNext(.setTitle(""))
                }
                context("after called Action.create") {
                    beforeEach {
                        sut.action.onNext(.create)
                    }
                    it("should showed toast") {
                        expect(mockToastService.isShowCalled).toEventually(beTrue())
                    }
                }
            }
        }
    }
}
