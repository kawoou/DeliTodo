//
//  AddTodoViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift
import RxValidator

final class AddTodoViewReactor: Reactor, Autowired {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let todoService: TodoService
    private let toastService: ToastService

    // MARK: - Reactor

    enum Action {
        case create

        case setTitle(String)
    }
    enum Mutation {
        case setTitle(String)

        case setLoading(Bool)
        case setCreated(Bool)
    }
    struct State {
        var title: String = ""

        var isLoading: Bool = false
        var isCreated: Bool = false
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .create:
            let startLoading = Observable.just(Mutation.setLoading(true))
            let addProcess = state.map { $0.title }
                .validate(.shouldNotBeEmpty, message: "Title is empty")
                .take(1)
                .flatMapLatest { [weak self] title -> Observable<String> in
                    guard let ss = self else { throw CommonError.nilSelf }
                    return ss.todoService.insert(title: title).asObservable()
                }
                .map { _ in Mutation.setCreated(true) }
                .catchError { [weak self] error in
                    switch error {
                    case let RxValidatorResult.notValidWithMessage(message):
                        self?.toastService.show(message, level: .normal)
                    default:
                        self?.toastService.show("Unknown error", level: .normal)
                    }

                    return .of(
                        Mutation.setLoading(false),
                        Mutation.setCreated(false)
                    )
                }

            return startLoading.concat(addProcess)

        case let .setTitle(title):
            return .just(.setTitle(title))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setTitle(title):
            state.title = title
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        case let .setCreated(isCreated):
            state.isCreated = isCreated
        }

        return state
    }

    // MARK: - Lifecycle

    required init(_ todoService: TodoService, _ toastService: ToastService) {
        self.todoService = todoService
        self.toastService = toastService
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
