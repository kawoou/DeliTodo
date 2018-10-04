//
//  SignUpViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 04/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxSwift

import Gradients
import TextFieldEffects

final class SignUpViewController: UIViewController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARL: - Interface

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
        view.returnKeyType = .next
        view.textColor = .white
        return view
    }()
    private lazy var nameField: HoshiTextField = {
        let view = HoshiTextField()
        view.placeholder = "Name"
        view.placeholderFontScale = 1.2
        view.placeholderColor = .white
        view.borderInactiveColor = UIColor.white.withAlphaComponent(0.5)
        view.borderActiveColor = .white
        view.returnKeyType = .done
        view.textColor = .white
        return view
    }()
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)
        button.setBackgroundImage(UIColor.gray.image(), for: .highlighted)
        button.clipsToBounds = true
        button.layer.cornerRadius = 6
        return button
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
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
        nameField.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(emailField)
            maker.top.equalTo(passwordField.snp.bottom).offset(40)
            maker.height.equalTo(60)
        }
        signUpButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(emailField)
            maker.top.equalTo(nameField.snp.bottom).offset(40)
            maker.height.equalTo(60)
        }
        cancelButton.snp.makeConstraints { maker in
            maker.leading.trailing.equalTo(emailField)
            maker.top.equalTo(signUpButton.snp.bottom).offset(20)
            maker.height.equalTo(60)
        }
        activityIndicatorView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
    }

    // MARL: - Public

    func bind(reactor: SignUpViewReactor) {
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

        reactor.state.map { $0.isSignedUp }
            .skip(1)
            .do(onNext: { [weak self] isSignedUp in
                self?.analytics.log(.signUp(isSuccess: isSignedUp))
            })
            .filter { $0 }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
                self?.navigator.navigate(to: .main)
            })
            .disposed(by: disposeBag)

        /// Action
        Observable
            .merge(
                emailField.rx.text.map { Reactor.Action.setEmail($0 ?? "") },
                passwordField.rx.text.map { Reactor.Action.setPassword($0 ?? "") },
                nameField.rx.text.map { Reactor.Action.setName($0 ?? "") }
            )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        signUpButton.rx.tap
            .do(onNext: { [weak self] _ in
                self?.analytics.log(.signUpDo)
            })
            .map { Reactor.Action.signUp }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] () in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.addSublayer(backgroundLayer)

        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(nameField)
        view.addSubview(signUpButton)
        view.addSubview(cancelButton)
        view.addSubview(activityIndicatorView)

        setupConstraints()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundLayer.frame = view.bounds
    }

    // MARK: - Lifecycle

    required init(_ reactor: SignUpViewReactor, _ analytics: AppAnalytics, _ navigator: Navigator) {
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
