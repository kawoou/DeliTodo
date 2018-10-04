//
//  ToastViewReactor.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Deli
import ReactorKit
import RxSwift

final class ToastViewReactor: Reactor, Autowired {

    // MARK: - Enumerable

    enum ToastEvent: Equatable {
        case none
        case show(Toast)
        case hide(Toast)
    }

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Private

    private let toastService: ToastService

    // MARK: - Reactor

    enum Action {
        case initial
        case setRunning(Bool)
    }
    enum Mutation {
        case setRunning(Bool)
        case showToast(Toast)
        case hideToast(Toast)
    }
    struct State {
        var event: ToastEvent = .none

        var isRunning: Bool = false
        var toastList: [Toast] = []
    }

    var initialState = State()

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initial:
            return state.map { $0.isRunning }
                .distinctUntilChanged()
                .flatMapLatest { [toastService] isRunning -> Observable<Toast> in
                    if isRunning {
                        return toastService.event.asObservable()
                    } else {
                        return .empty()
                    }
                }
                .flatMap { toast -> Observable<Mutation> in
                    let showToast = Observable.just(Mutation.showToast(toast))
                    let hideToast = Observable.just(Mutation.hideToast(toast))
                        .delay(TimeInterval(toast.duration), scheduler: MainScheduler.instance)

                    return showToast.concat(hideToast)
                }

        case let .setRunning(isRunning):
            return .just(Mutation.setRunning(isRunning))
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setRunning(isRunning):
            state.isRunning = isRunning

        case let .showToast(toast):
            logger.debug("showToast(\(toast.uuid)): \(toast.message)")

            state.event = .show(toast)
            state.toastList.append(toast)

        case let .hideToast(toast):
            logger.debug("hideToast(\(toast.uuid)): \(toast.message)")

            state.event = .hide(toast)
            state.toastList.removeAll { $0.uuid == toast.uuid }
        }

        return state
    }

    // MARK: - Lifecycle

    required init(_ toastService: ToastService) {
        self.toastService = toastService

        action.onNext(.initial)
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
