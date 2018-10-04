//
//  TodoCellReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift

final class TodoCellPayload: Payload {
    let todo: Todo

    required init(with argument: (Todo)) {
        self.todo = argument
    }
}

final class TodoCellReactor: Reactor, AutowiredFactory {

    // MARK: - Private

    private let todoService: TodoService

    // MARK: - Reactor

    enum Action {
        case setPressing(Bool)
        case setChecked(Bool)
    }
    enum Mutation {
        case setPressing(Bool)
        case setChecked(Bool)
    }
    struct State {
        var id: String = ""
        var title: String = ""
        var isPressing: Bool = false
        var isChecked: Bool = false
    }

    var initialState: State

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setPressing(isPressing):
            return .just(.setPressing(isPressing))
        case let .setChecked(isChecked):
            return todoService.get(id: currentState.id)
                .asObservable()
                .map { todo -> Todo in
                    var todo = todo
                    todo.isChecked = isChecked
                    return todo
                }
                .flatMapLatest { [weak self] todo -> Observable<Void> in
                    guard let ss = self else { throw CommonError.nilSelf }
                    return ss.todoService.update(todo: todo).asObservable()
                }
                .map { _ in Mutation.setChecked(isChecked) }
                .asObservable()
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setPressing(isPressing):
            state.isPressing = isPressing
        case let .setChecked(isChecked):
            state.isChecked = isChecked
        }

        return state
    }

    // MARK: - Lifecycle

    required init(_ todoService: TodoService, payload: TodoCellPayload) {
        self.todoService = todoService

        initialState = State(
            id: payload.todo.id,
            title: payload.todo.title,
            isPressing: false,
            isChecked: payload.todo.isChecked
        )
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
