//
//  TodoServiceImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import RxSwift

final class TodoServiceImpl: TodoService, Autowired {

    // MARK: - Private

    private let todoRepository: TodoRepository
    private let authService: AuthService

    private let disposeBag = DisposeBag()

    private func bindEvents() {
        authService.observeUser()
            .distinctUntilChanged { (i, j) -> Bool in
                switch (i, j) {
                case (.none, .none):
                    return true
                default:
                    return false
                }
            }
            .scan((nil, nil)) { (old, new) -> (User?, User?) in
                return (old.1, new)
            }
            .filter { $0.1 == nil }
            .flatMapLatest { [weak self] (user, _) -> Observable<Void> in
                guard let ss = self else { return .empty() }
                guard let user = user else { return .empty() }
                return ss.todoRepository.clear(for: user).asObservable()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    // MARK: - Public

    func get(id: String) -> Single<Todo> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }
        return todoRepository.get(id: id, for: user)
    }
    func gets() -> Single<[Todo]> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }
        return todoRepository.gets(for: user)
    }

    func observe(id: String) -> Observable<Todo?> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }
        return todoRepository.observe(id: id, for: user)
    }
    func observes() -> Observable<[Todo]> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }
        return todoRepository.observes(for: user)
    }

    func insert(title: String) -> Single<String> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }
        return todoRepository.insert(
            Todo(
                id: UniqueManager.generate(),
                title: title,
                isChecked: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            for: user
        )
    }
    func update(todo: Todo) -> Single<Void> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }

        var todo = todo
        todo.updatedAt = Date()
        return todoRepository.update(todo, for: user)
    }
    func delete(id: String) -> Single<Void> {
        guard let user = authService.currentUser() else {
            return .error(TodoServiceError.userNotFound)
        }
        return todoRepository.delete(id: id, for: user)
    }

    // MARK: - Lifecycle
    
    required init(local todoRepository: TodoRepository, _ authService: AuthService) {
        self.todoRepository = todoRepository
        self.authService = authService

        bindEvents()
    }
}
