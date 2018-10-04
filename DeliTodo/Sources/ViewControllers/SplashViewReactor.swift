//
//  SplashViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift
import RxOptional

final class SplashViewReactor: Reactor, Autowired {

    // MARL: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let authService: AuthService

    // MARK: - Reactor

    enum Action {
        case checkAuthenticated
    }
    enum Mutation {
        case setAuthenticated(Bool)
    }
    struct State {
        var isAuthenticated: Bool = false
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkAuthenticated:
            return Observable.just(authService.currentUser())
                .map { $0 != nil }
                .map(Mutation.setAuthenticated)
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setAuthenticated(isAuthenticated):
            state.isAuthenticated = isAuthenticated
        }

        return state
    }

    // MARK: - Lifecycle

    required init(_ authService: AuthService) {
        self.authService = authService
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
