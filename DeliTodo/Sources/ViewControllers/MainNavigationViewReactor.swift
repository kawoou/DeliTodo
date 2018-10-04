//
//  MainNavigationViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift

final class MainNavigationViewReactor: Reactor, Component {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Enumerable

    enum Tab: Int, CaseIterable, Equatable {
        case todo
        case more
    }

    // MARK: - Reactor

    enum Action {
        case changeTab(Tab)
    }
    enum Mutation {
        case changeTab(Tab)
    }
    struct State {
        var currentTab: Tab = .todo
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .changeTab(tab):
            return .just(.changeTab(tab))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .changeTab(tab):
            state.currentTab = tab
        }

        return state
    }

    // MARK: - Lifecycle

    init() {}
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
