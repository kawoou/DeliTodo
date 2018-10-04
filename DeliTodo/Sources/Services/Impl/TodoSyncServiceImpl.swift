//
//  TodoSyncServiceImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import RxCocoa
import RxSwift

import NotificationBanner

final class TodoSyncServiceImpl: SyncService, Autowired {
    
    // MARK: - Deli
    
    var qualifier: String? = "todo"
    var scope: Scope = .always

    // MARK: - Private

    private let localTodoRepository: TodoRepository
    private let remoteTodoRepository: TodoRepository
    private let authService: AuthService
    private let scheduler: SchedulerType

    private let disposeBag = DisposeBag()

    private func bindEvents() {
        authService.observeUser()
            .scan((authService.currentUser(), authService.currentUser())) { (old, new) -> (User?, User?) in
                return (old.1, new)
            }
            .flatMapLatest { [unowned self] users -> Observable<User> in
                guard let user = users.1 else { return .empty() }
                guard users.0 == nil else { return .just(user) }

                return self.remoteTodoRepository.gets(for: user)
                    .asObservable()
                    .flatMapLatest { list in
                        return self.localTodoRepository.clear(for: user)
                            .asObservable()
                            .map { list }
                    }
                    .flatMapLatest { list -> Observable<Void> in
                        return Observable.merge(list.map { todo -> Observable<Void> in
                            self.localTodoRepository.insert(todo, for: user).asObservable().map { _ in Void() }
                        })
                    }
                    .map { user }
            }
            .flatMapLatest { [unowned self] user -> Observable<([Todo], [Todo])> in
                return Observable
                    .combineLatest(
                        self.remoteTodoRepository.observes(for: user),
                        self.localTodoRepository.observes(for: user)
                    )
            }
            .flatMap { [unowned self] tuple -> Observable<Void> in
                guard let user = self.authService.currentUser() else { return .empty() }

                var oldDict = [String: Todo]()
                var newDict = [String: Todo]()

                for todo in tuple.0 {
                    oldDict[todo.id] = todo
                }
                for todo in tuple.1 {
                    newDict[todo.id] = todo
                }

                /// Add Todo
                for (id, value) in newDict where oldDict[id] == nil {
                    return self.remoteTodoRepository.insert(value, for: user)
                        .asObservable()
                        .map { _ in Void() }
                }

                /// Update Todo
                for (id, value) in newDict {
                    guard let old = oldDict[id] else { continue }
                    guard old != value else { continue }
                    return self.remoteTodoRepository.update(value, for: user).asObservable()
                }

                /// Delete Todo
                for (id, _) in oldDict where newDict[id] == nil {
                    return self.remoteTodoRepository.delete(id: id, for: user).asObservable()
                }

                DispatchQueue.main.async {
                    let banner = StatusBarNotificationBanner(title: "Sync complete", style: .success)
                    banner.duration = 1
                    banner.show()
                }
                return .empty()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    // MARK: - Lifecycle
    
    required init(
        local localTodoRepository: TodoRepository,
        remote remoteTodoRepository: TodoRepository,
        _ authService: AuthService,
        sync scheduler: SchedulerType
    ) {
        self.localTodoRepository = localTodoRepository
        self.remoteTodoRepository = remoteTodoRepository
        self.authService = authService
        self.scheduler = scheduler

        bindEvents()
    }
}
