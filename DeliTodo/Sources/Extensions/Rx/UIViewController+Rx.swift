//
//  UIViewController+Rx.swift
//  DeliTodo
//
//  Created by Kawoou on 04/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewDidLoad))
                .map { _ in Void() }
        )
    }
    var viewWillAppear: ControlEvent<Bool> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewWillAppear))
                .map { $0.first as? Bool ?? false }
        )
    }
    var viewDidAppear: ControlEvent<Bool> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewDidAppear))
                .map { $0.first as? Bool ?? false }
        )
    }
    var viewWillDisappear: ControlEvent<Bool> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewWillDisappear))
                .map { $0.first as? Bool ?? false }
        )
    }
    var viewDidDisappear: ControlEvent<Bool> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewDidDisappear))
                .map { $0.first as? Bool ?? false }
        )
    }
    var viewWillLayoutSubviews: ControlEvent<Void> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewWillLayoutSubviews))
                .map { _ in Void() }
        )
    }
    var viewDidLayoutSubviews: ControlEvent<Void> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.viewDidLayoutSubviews))
                .map { _ in Void() }
        )
    }
    var didReceiveMemoryWarning: ControlEvent<Void> {
        return ControlEvent(
            events: methodInvoked(#selector(Base.didReceiveMemoryWarning))
                .map { _ in Void() }
        )
    }
}
