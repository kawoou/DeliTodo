//
//  ToastServiceSpec.swift
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

final class ToastServiceSpec: QuickSpec {
    override func spec() {
        super.spec()

        var sut: ToastService!
        var disposeBag: DisposeBag!

        beforeEach {
            sut = AppContext.shared.get(ToastService.self)

            disposeBag = DisposeBag()
        }
        describe("ToastService's") {
            var toastEvent = [Toast]()

            beforeEach {
                toastEvent = []

                sut.event
                    .subscribe(onNext: { toastEvent.append($0) })
                    .disposed(by: disposeBag)
            }
            context("when called show()") {
                beforeEach {
                    sut.show("Test Message", level: .normal)
                }
                it("should received toast") {
                    expect(toastEvent.first?.message).toEventually(equal("Test Message"))
                    expect(toastEvent.first?.level).toEventually(equal(.normal))
                    expect(toastEvent.first?.duration).toEventually(equal(3))
                }
            }
        }
    }
}
