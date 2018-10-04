//
//  AddTodoViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxSwift
import SnapKit

import TextFieldEffects

final class AddTodoViewController: UIViewController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var cancelButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        return item
    }()
    private lazy var doneButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        return item
    }()

    private lazy var titleField: HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = "Title"
        view.placeholderFontScale = 1
        view.placeholderColor = .black
        view.borderInactiveColor = UIColor.black.withAlphaComponent(0.5)
        view.borderActiveColor = .black
        view.returnKeyType = .done
        view.textColor = .black
        return view
    }()

    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .gray)

    // MARK: - Private

    private func setupConstraints() {
        titleField.snp.makeConstraints { maker in
            maker.topMargin.equalToSuperview().offset(20)
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(60)
        }
        activityIndicatorView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }

    // MARK: - Public

    func bind(reactor: AddTodoViewReactor) {
        /// State
        reactor.state.map { $0.title.isNotEmpty }
            .distinctUntilChanged()
            .bind(to: doneButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.view.isUserInteractionEnabled = false
                    self?.activityIndicatorView.startAnimating()
                } else {
                    self?.view.isUserInteractionEnabled = true
                    self?.activityIndicatorView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isCreated }
            .skip(1)
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        /// Action
        titleField.rx.text.map { Reactor.Action.setTitle($0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        cancelButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] () in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        doneButtonItem.rx.tap
            .map { Reactor.Action.create }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Add Todo"
        navigationItem.leftBarButtonItem = cancelButtonItem
        navigationItem.rightBarButtonItem = doneButtonItem

        view.backgroundColor = .white
        view.addSubview(titleField)
        view.addSubview(activityIndicatorView)

        setupConstraints()
    }

    // MARK: - Lifecycle

    required init(_ reactor: AddTodoViewReactor) {
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
