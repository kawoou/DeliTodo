//
//  MoreCellReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift

class MoreCellPayload: Payload {
    let title: String

    required init(with argument: (String)) {
        self.title = argument
    }
}

final class MoreCellReactor: Reactor, AutowiredFactory {

    // MARK: - Reactor

    typealias Action = NoAction
    typealias Mutation = NoMutation
    struct State {
        var title: String = ""
    }

    var initialState: State

    // MARK: - Lifecycle

    required init(payload: MoreCellPayload) {
        initialState = State(title: payload.title)
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
