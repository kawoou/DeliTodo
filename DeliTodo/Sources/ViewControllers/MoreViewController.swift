//
//  MoreViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxDataSources
import RxSwift

final class MoreViewController: UIViewController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(MoreCell.self, forCellReuseIdentifier: "cell")

        view.contentInset.bottom = 49
        view.scrollIndicatorInsets.bottom = 49
        return view
    }()

    // MARK: - Private

    private let navigator: Navigator
    private let analytics: AppAnalytics

    private lazy var dataSource: RxTableViewSectionedReloadDataSource<MoreSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<MoreSection>(configureCell: { (_, tableView, _, item) in
            switch item {
            case .row(let reactor):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? MoreCell else {
                    return MoreCell()
                }
                cell.reactor = reactor

                return cell
            }
        })
        dataSource.titleForHeaderInSection = { [weak self] (dataSource, index) in
            guard let section = self?.reactor?.currentState.sections[index] else { return nil }
            guard case .items(_, title: let title) = section else { return nil }
            return title
        }
        return dataSource
    }()

    private func setupConstraints() {
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }

    // MARK: - Public

    func bind(reactor: MoreViewReactor) {
        /// State
        reactor.state.map { $0.sections }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        reactor.state.map { $0.isLoggedOut }
            .asDriver(onErrorJustReturn: false)
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                self?.navigator.navigate(to: .login)
            })
            .disposed(by: disposeBag)

        /// Action
        tableView.rx.itemSelected
            .flatMapLatest { indexPath -> Observable<Reactor.Action> in
                switch indexPath.item {
                case 0:
                    return .just(.logout)
                default:
                    return .empty()
                }
            }
            .do(onNext: { [weak self] action in
                switch action {
                case .logout:
                    self?.analytics.log(.moreLogout)
                }
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "More"
        view.addSubview(tableView)

        setupConstraints()
    }

    // MARK: - Lifecycle

    required init(_ reactor: MoreViewReactor, _ navigator: Navigator, _ analytics: AppAnalytics) {
        defer { self.reactor = reactor }
        self.navigator = navigator
        self.analytics = analytics

        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
