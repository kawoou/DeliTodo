//
//  SplashViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxSwift
import SnapKit
import Gradients

final class SplashViewController: UIViewController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var backgroundLayer = Gradients.nightSky.layer()

    private lazy var appLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.text = "Deli Todo"
        label.textColor = .white
        return label
    }()
    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .white)

    // MARK: - Private

    private let navigator: Navigator

    private func setupConstraints() {
        appLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        activityIndicatorView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(appLabel.snp.bottom).offset(20)
        }
    }

    // MARK: - Public

    func bind(reactor: SplashViewReactor) {
        /// State
        reactor.state.map { $0.isAuthenticated }
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isAuthenticated in
                if !isAuthenticated {
                    self?.navigator.navigate(to: .login)
                } else {
                    self?.navigator.navigate(to: .main)
                }
            })
            .disposed(by: self.disposeBag)

        /// Action
        rx.viewDidAppear
            .take(1)
            .map { _ in Reactor.Action.checkAuthenticated }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.addSublayer(backgroundLayer)

        view.addSubview(appLabel)
        view.addSubview(activityIndicatorView)

        activityIndicatorView.startAnimating()

        setupConstraints()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundLayer.frame = view.bounds
    }

    // MARK: - Lifecycle

    required init(_ reactor: SplashViewReactor, _ navigator: Navigator) {
        defer { self.reactor = reactor }
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
