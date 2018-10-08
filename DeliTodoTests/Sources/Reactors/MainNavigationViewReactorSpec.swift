//
//  MainNavigationViewReactorSpec.swift
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

final class MainNavigationViewReactorSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: MainNavigationViewReactor!

        beforeEach {
            sut = AppContext.shared.get(MainNavigationViewReactor.self)
        }
        describe("MainNavigationViewReactor's") {
            context("when change tab 'more'") {
                beforeEach {
                    sut.action.onNext(.changeTab(.more))
                }
                it("state.currentTab should equal to 'more'") {
                    expect(sut.currentState.currentTab).toEventually(equal(.more))
                }
            }
        }
    }
}
