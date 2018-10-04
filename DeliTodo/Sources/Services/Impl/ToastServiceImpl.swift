//
//  ToastServiceImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Deli
import RxCocoa
import RxSwift

final class ToastServiceImpl: ToastService, Component {

    // MARK: - Property

    let event = PublishRelay<Toast>()

    // MARK: - Public

    @discardableResult
    func show(_ message: String, level: Toast.Level) -> UUID {
        let toast = Toast(message: message, level: level, duration: 3)
        event.accept(toast)

        return toast.uuid
    }
}
