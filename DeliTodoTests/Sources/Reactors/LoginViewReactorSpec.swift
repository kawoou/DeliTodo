//
//  LoginViewReactorSpec.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Quick
import Nimble

import Deli
import RxCocoa
import RxSwift

@testable import DeliTodo

final class LoginViewReactorSpec: QuickSpec {
    override func spec() {
        super.spec()

        var mockAuthService: MockAuthService!
        var mockToastService: MockToastService!
        var sut: LoginViewReactor!

        beforeEach {
            testModule.register(
                MockAuthService.self,
                resolver: { MockAuthService() },
                qualifier: "",
                scope: .singleton
            ).link(AuthService.self)

            testModule.register(
                MockToastService.self,
                resolver: { MockToastService() },
                qualifier: "",
                scope: .singleton
            ).link(ToastService.self)

            testModule.register(
                AppAnalytics.self,
                resolver: {
                    let analytics = AppAnalytics()
                    analytics.register(provider: MockAnalyticsProvider())
                    return analytics
                },
                qualifier: "",
                scope: .singleton
            )

            mockAuthService = AppContext.shared.get(MockAuthService.self)
            mockToastService = AppContext.shared.get(MockToastService.self)
            sut = AppContext.shared.get(LoginViewReactor.self)
        }
        describe("LoginViewReactor's") {
            context("when set email") {
                beforeEach {
                    sut.action.onNext(.setPassword("12345678"))
                }
                context("to empty email") {
                    beforeEach {
                        sut.action.onNext(.setEmail(""))
                    }
                    context("after called Action.login") {
                        beforeEach {
                            sut.action.onNext(.login)
                        }
                        it("should showed toast") {
                            expect(mockToastService.isShowCalled).toEventually(beTrue())
                        }
                    }
                }
                context("to not email address") {
                    beforeEach {
                        sut.action.onNext(.setEmail("test@test"))
                    }
                    context("after called Action.login") {
                        beforeEach {
                            sut.action.onNext(.login)
                        }
                        it("should showed toast") {
                            expect(mockToastService.isShowCalled).toEventually(beTrue())
                        }
                    }
                }
                context("to long email") {
                    beforeEach {
                        sut.action.onNext(.setEmail("12345678901234567890123456789012345678901234567890@email.com"))
                    }
                    context("after called Action.login") {
                        beforeEach {
                            sut.action.onNext(.login)
                        }
                        it("should showed toast") {
                            expect(mockToastService.isShowCalled).toEventually(beTrue())
                        }
                    }
                }
                context("to allowed email") {
                    beforeEach {
                        sut.action.onNext(.setEmail("test@test.com"))
                    }
                    context("after called Action.login") {
                        context("success test") {
                            beforeEach {
                                mockAuthService.expectedLogin = .just(DummyUser.user)
                                sut.action.onNext(.login)
                            }
                            it("state.isLoggedIn should be true") {
                                expect(sut.currentState.isLoading).toEventually(beTrue())
                                expect(mockAuthService.isLoginCalled).toEventually(beTrue())
                                expect(sut.currentState.isLoggedIn).toEventually(beTrue())
                            }
                        }
                        context("failed test") {
                            beforeEach {
                                mockAuthService.expectedLogin = .error(MockError.notImplementated)
                                sut.action.onNext(.login)
                            }
                            it("should showed toast") {
                                expect(mockToastService.isShowCalled).toEventually(beTrue())
                            }
                        }
                    }
                }
            }
            context("when set password") {
                beforeEach {
                    sut.action.onNext(.setEmail("test@test.com"))
                }
                context("to empty password") {
                    beforeEach {
                        sut.action.onNext(.setPassword(""))
                    }
                    context("after called Action.login") {
                        beforeEach {
                            sut.action.onNext(.login)
                        }
                        it("should showed toast") {
                            expect(mockToastService.isShowCalled).toEventually(beTrue())
                        }
                    }
                }
                context("to short password") {
                    beforeEach {
                        sut.action.onNext(.setPassword("12345"))
                    }
                    context("after called Action.login") {
                        beforeEach {
                            sut.action.onNext(.login)
                        }
                        it("should showed toast") {
                            expect(mockToastService.isShowCalled).toEventually(beTrue())
                        }
                    }
                }
                context("to allowed password") {
                    beforeEach {
                        sut.action.onNext(.setPassword("12345678"))
                    }
                    context("after called Action.login") {
                        context("success test") {
                            beforeEach {
                                mockAuthService.expectedLogin = .just(DummyUser.user)
                                sut.action.onNext(.login)
                            }
                            it("state.isLoggedIn should be true") {
                                expect(sut.currentState.isLoading).toEventually(beTrue())
                                expect(mockAuthService.isLoginCalled).toEventually(beTrue())
                                expect(sut.currentState.isLoggedIn).toEventually(beTrue())
                            }
                        }
                        context("failed test") {
                            beforeEach {
                                mockAuthService.expectedLogin = .error(MockError.notImplementated)
                                sut.action.onNext(.login)
                            }
                            it("should showed toast") {
                                expect(mockToastService.isShowCalled).toEventually(beTrue())
                            }
                        }
                    }
                }
            }

        }
    }
}
