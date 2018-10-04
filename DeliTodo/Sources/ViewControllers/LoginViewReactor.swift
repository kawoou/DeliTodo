//
//  LoginViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift
import RxValidator

final class LoginViewReactor: Reactor, Autowired {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let authService: AuthService
    private let toastService: ToastService
    private let analytics: AppAnalytics

    // MARK: - Reactor

    enum Action {
        case login
        case setEmail(String)
        case setPassword(String)
    }
    enum Mutation {
        case setEmail(String)
        case setPassword(String)
        case setLoading(Bool)
        case setLoggedIn(Bool)
    }
    struct State {
        var email: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var isLoggedIn: Bool = false
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .login:
            return Observable
                .combineLatest(
                    state.map { $0.email }
                        .validate(.shouldNotBeEmpty, message: "Empty email.")
                        .validate(.isNotOverflowThen(max: 50), message: "Overflow email.")
                        .validate(.shouldBeMatch("[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+\\.[a-zA-Z]+"), message: "Not matched email pattern."),
                    state.map { $0.password }
                        .validate(.isNotUnderflowThen(min: 6), message: "Underflow password.")
                ) { Credential(email: $0, password: $1) }
                .take(1)
                .flatMapLatest { [weak self] credential -> Observable<Mutation> in
                    guard let ss = self else { return .empty() }

                    let setLoading = Observable.just(Mutation.setLoading(true))
                    let loginProcess = ss.authService.login(credential: credential)
                        .asObservable()
                        .map { _ in Mutation.setLoggedIn(true) }
                        .catchError { [weak self] _ in
                            self?.toastService.show("Login failed", level: .normal)
                            return .of(
                                Mutation.setLoading(false),
                                Mutation.setLoggedIn(false)
                            )
                        }

                    return setLoading.concat(loginProcess)
                }
                .catchError { [weak self] error in
                    switch error {
                    case let RxValidatorResult.notValidWithMessage(message):
                        self?.toastService.show(message, level: .normal)
                    default:
                        self?.analytics.log(.loginUnknownError(message: error.localizedDescription))
                        self?.toastService.show("Login failed", level: .normal)
                    }
                    return .just(.setLoggedIn(false))
                }

        case let .setEmail(email):
            return .just(Mutation.setEmail(email))

        case let .setPassword(password):
            return .just(Mutation.setPassword(password))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setEmail(email):
            state.email = email

        case let .setPassword(password):
            state.password = password

        case let .setLoading(isLoading):
            state.isLoading = isLoading

        case let .setLoggedIn(isLoggedIn):
            state.isLoggedIn = isLoggedIn
        }

        return state
    }

    // MARK: - Lifecycle

    required init(_ authService: AuthService, _ toastService: ToastService, _ analytics: AppAnalytics) {
        self.authService = authService
        self.toastService = toastService
        self.analytics = analytics
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
