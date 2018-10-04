//
//  ToastService.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ToastService {
    var event: PublishRelay<Toast> { get }

    @discardableResult
    func show(_ message: String, level: Toast.Level) -> UUID
}
