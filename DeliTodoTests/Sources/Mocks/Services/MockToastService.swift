//
//  MockToastService.swift
//  DeliTodoTests
//
//  Created by Kawoou on 09/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

@testable import DeliTodo

final class MockToastService: ToastService {

    // MARK: - Expect

    var expectedShow: UUID = UUID()
    var isShowCalled: Bool = false
    var numberOfShowCalled: Int = 0

    // MARK: - Protocol

    let event = PublishRelay<Toast>()

    @discardableResult
    func show(_ message: String, level: Toast.Level) -> UUID {
        isShowCalled = true
        numberOfShowCalled += 1
        return expectedShow
    }

}
