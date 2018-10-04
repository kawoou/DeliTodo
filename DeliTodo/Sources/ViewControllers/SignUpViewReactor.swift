//
//  SignUpViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 04/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift
import RxValidator

final class SignUpViewReactor: Reactor, Autowired {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let authService: AuthService
    private let toastService: ToastService
    private let analytics: AppAnalytics

    // MARK: - Reactor

    enum Action {
        case setEmail(String)
        case setPassword(String)
        case setName(String)

        case signUp
    }
    enum Mutation {
        case setEmail(String)
        case setPassword(String)
        case setName(String)

        case setLoading(Bool)
        case setSignedUp(Bool)
    }
    struct State {
        var email: String = ""
        var password: String = ""
        var name: String = ""

        var isLoading: Bool = false
        var isSignedUp: Bool = false
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .signUp:
            return Observable
                .combineLatest(
                    state.map { $0.email }
                        .validate(.shouldNotBeEmpty, message: "Empty email.")
                        .validate(.isNotOverflowThen(max: 50), message: "Overflow email.")
                        .validate(.shouldBeMatch("[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+\\.[a-zA-Z]+"), message: "Not matched email pattern."),
                    state.map { $0.password }
                        .validate(.isNotUnderflowThen(min: 6), message: "Underflow password."),
                    state.map { $0.name }
                        .validate(.shouldNotBeEmpty, message: "Empty name.")
                ) { (Credential(email: $0, password: $1), $2) }
                .take(1)
                .flatMapLatest { [weak self] (credential, name) -> Observable<Mutation> in
                    guard let ss = self else { return .empty() }

                    let user = User(
                        id: "",
                        email: credential.email,
                        name: name
                    )

                    let setLoading = Observable.just(Mutation.setLoading(true))
                    let signUpProcess = ss.authService.signUp(credential: credential, user: user)
                        .asObservable()
                        .map { _ in Mutation.setSignedUp(true) }
                        .catchError { [weak self] _ in
                            self?.toastService.show("Sign-up failed", level: .normal)
                            return .of(
                                Mutation.setLoading(false),
                                Mutation.setSignedUp(false)
                            )
                        }

                    return setLoading.concat(signUpProcess)
                }
                .catchError { [weak self] error in
                    switch error {
                    case let RxValidatorResult.notValidWithMessage(message):
                        self?.toastService.show(message, level: .normal)
                    default:
                        self?.analytics.log(.signUpUnknownError(message: error.localizedDescription))
                        self?.toastService.show("Sign-up failed", level: .normal)
                    }
                    return .just(.setSignedUp(false))
                }

        case let .setEmail(email):
            return .just(Mutation.setEmail(email))

        case let .setPassword(password):
            return .just(Mutation.setPassword(password))

        case let .setName(name):
            return .just(Mutation.setName(name))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setEmail(email):
            state.email = email
            
        case let .setPassword(password):
            state.password = password

        case let .setName(name):
            state.name = name

        case let .setLoading(isLoading):
            state.isLoading = isLoading

        case let .setSignedUp(isSignedUp):
            state.isSignedUp = isSignedUp
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
