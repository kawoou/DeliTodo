//
//  MoreViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift

final class MoreViewReactor: Reactor, Autowired {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let authService: AuthService

    // MARK: - Reactor

    enum Action {
        case logout
    }
    enum Mutation {
        case setLoggedOut(Bool)
    }
    struct State {
        var sections: [MoreSection] = [
            .items([
                .row(Inject(MoreCellReactor.self, with: ("Logout")))
            ], title: "")
        ]
        var isLoggedOut: Bool = false
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .logout:
            return authService.logout()
                .asObservable()
                .map { Mutation.setLoggedOut(true) }
                .catchError { _ in .just(.setLoggedOut(false)) }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setLoggedOut(isLoggedOut):
            state.isLoggedOut = isLoggedOut
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
