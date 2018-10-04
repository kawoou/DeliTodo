//
//  TodoViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift

final class TodoViewReactor: Reactor, Autowired {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let todoService: TodoService

    // MARK: - Reactor

    enum Action {
        case initial

        case delete(id: String)
    }
    enum Mutation {
        case updateSections([TodoSection])
    }
    struct State {
        var sections: [TodoSection] = []
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initial:
            return todoService.observes()
                .map { [weak self] todoList -> [TodoItem] in
                    guard let ss = self else { return [] }
                    return todoList
                        .sorted(by: { (cell1, cell2) -> Bool in
                            return cell1.createdAt > cell2.createdAt
                        })
                        .map { ss.Inject(TodoCellReactor.self, with: ($0)) }
                        .map { TodoItem.row($0) }
                }
                .map { .updateSections([TodoSection.items($0)]) }

        case let .delete(id):
            return todoService.delete(id: id)
                .asObservable()
                .flatMapLatest { Observable.empty() }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .updateSections(sections):
            state.sections = sections
        }

        return state
    }

    // MARK: - Lifecycle

    required init(_ todoService: TodoService) {
        self.todoService = todoService
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
