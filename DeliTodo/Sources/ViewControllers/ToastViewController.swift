//
//  ToastViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxSwift
import SnapKit

final class ToastViewController: UIViewController, View, Autowired {

    // MARK: - Constant

    private struct Constant {
        static let toastMargin: CGFloat = 10
    }

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var toastBaseView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    // MARK: - Private

    private var toastDict: [UUID: ToastView] = [:]

    private func setupConstraints() {
        toastBaseView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }

    private func showToast(_ toast: Toast) {
        let toastView = Inject(ToastView.self, with: (toast))

        let size = toastView.sizeThatFits(CGSize(width: view.bounds.width - 40, height: .greatestFiniteMagnitude))
        toastView.frame = CGRect(x: (view.bounds.width - size.width) / 2, y: view.bounds.height + Constant.toastMargin, width: size.width, height: size.height)
        toastBaseView.addSubview(toastView)
        toastDict[toast.uuid] = toastView

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.35)

        for toast in toastDict.values {
            if toast === toastView {
                toast.frame.origin.y -= (size.height + view.safeAreaInsets.bottom + Constant.toastMargin)
            } else {
                toast.frame.origin.y -= (size.height + Constant.toastMargin)
            }
        }

        UIView.commitAnimations()
    }
    private func hideToast(_ toast: Toast) {
        guard let view = toastDict[toast.uuid] else { return }
        UIView.animate(withDuration: 0.35, animations: {
            view.alpha = 0
        }, completion: { [weak self] _ in
            view.removeFromSuperview()
            self?.toastDict.removeValue(forKey: toast.uuid)
        })
    }

    // MARK: - Public

    func bind(reactor: ToastViewReactor) {
        /// State
        reactor.state.map { $0.event }
            .distinctUntilChanged { $0 == $1 }
            .asDriver(onErrorJustReturn: .none)
            .drive(onNext: { [weak self] event in
                switch event {
                case let .show(toast):
                    self?.showToast(toast)
                case let .hide(toast):
                    self?.hideToast(toast)
                case .none:
                    break
                }
            })
            .disposed(by: disposeBag)

        /// Action
        reactor.action.onNext(.setRunning(true))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toastBaseView)

        setupConstraints()
    }

    // MARK: - Lifecycle

    required init(_ reactor: ToastViewReactor) {
        defer { self.reactor = reactor }
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
