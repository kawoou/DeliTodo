//
//  LoginViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 04/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxSwift
import SnapKit

import Gradients
import TextFieldEffects

final class LoginViewController: UIViewController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var backgroundLayer = Gradients.nightSky.layer()

    private lazy var emailField: HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = "Email"
        view.placeholderFontScale = 1.2
        view.placeholderColor = .white
        view.borderInactiveColor = UIColor.white.withAlphaComponent(0.5)
        view.borderActiveColor = .white
        view.keyboardType = .emailAddress
        view.returnKeyType = .next
        view.textColor = .white
        return view
    }()
    private lazy var passwordField: HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = "Password"
        view.placeholderFontScale = 1.2
        view.placeholderColor = .white
        view.borderInactiveColor = UIColor.white.withAlphaComponent(0.5)
        view.borderActiveColor = .white
        view.isSecureTextEntry = true
        view.returnKeyType = .done
        view.textColor = .white
        return view
    }()
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)
        button.setBackgroundImage(UIColor.gray.image(), for: .highlighted)
        button.clipsToBounds = true
        button.layer.cornerRadius = 6
        return button
    }()
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Join", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)
        button.setBackgroundImage(UIColor.gray.image(), for: .highlighted)
        button.clipsToBounds = true
        button.layer.cornerRadius = 6
        return button
    }()

    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .white)

    // MARK: - Private

    private let analytics: AppAnalytics
    private let navigator: Navigator

    private func setupConstraints() {
        emailField.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(20)
            maker.top.equalToSuperview().offset(100)
            maker.height.equalTo(60)
        }
        passwordField.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(emailField)
            maker.top.equalTo(emailField.snp.bottom).offset(40)
            maker.height.equalTo(60)
        }
        loginButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(emailField)
            maker.top.equalTo(passwordField.snp.bottom).offset(40)
            maker.height.equalTo(60)
        }
        signUpButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(emailField)
            maker.top.equalTo(loginButton.snp.bottom).offset(20)
            maker.height.equalTo(loginButton)
        }
        activityIndicatorView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }

    // MARK: - Public

    func bind(reactor: LoginViewReactor) {
        /// View
        signUpButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] () in
                guard let ss = self else { return }
                ss.present(ss.Inject(SignUpViewController.self), animated: true)
            })
            .disposed(by: disposeBag)

        /// State
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

        reactor.state.map { $0.isLoggedIn }
            .skip(1)
            .do(onNext: { [weak self] isLoggedIn in
                self?.analytics.log(.login(isSuccess: isLoggedIn))
            })
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.navigator.navigate(to: .main)
            })
            .disposed(by: disposeBag)

        /// Action
        Observable
            .merge(
                emailField.rx.text.map { Reactor.Action.setEmail($0 ?? "") },
                passwordField.rx.text.map { Reactor.Action.setPassword($0 ?? "") }
            )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .do(onNext: { [weak self] _ in
                self?.view.endEditing(true)

                self?.analytics.log(.loginDo)
            })
            .map { Reactor.Action.login }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.addSublayer(backgroundLayer)

        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(activityIndicatorView)

        setupConstraints()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundLayer.frame = view.bounds
    }

    // MARK: - Lifecycle

    required init(_ reactor: LoginViewReactor, _ analytics: AppAnalytics, _ navigator: Navigator) {
        defer { self.reactor = reactor }
        self.analytics = analytics
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
