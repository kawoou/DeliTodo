//
//  SplashViewReactorSpec.swift
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

final class SplashViewReactorSpec: QuickSpec {
    override func spec() {
        super.spec()

        var mockAuthService: MockAuthService!
        var sut: SplashViewReactor!

        beforeEach {
            testModule.register(
                MockAuthService.self,
                resolver: { MockAuthService() },
                qualifier: "",
                scope: .singleton
            ).link(AuthService.self)

            mockAuthService = AppContext.shared.get(MockAuthService.self)
            sut = AppContext.shared.get(SplashViewReactor.self)
        }
        describe("SplashViewReactor's") {
            context("when called Action.checkAuthenticated") {
                context("with logged-in") {
                    beforeEach {
                        mockAuthService.expectedCurrentUser = DummyUser.user
                        sut.action.onNext(.checkAuthenticated)
                    }
                    it("state.isAuthenticated should be true") {
                        expect(sut.currentState.isAuthenticated).toEventually(beTrue())
                    }
                }
            }
        }
    }
}
