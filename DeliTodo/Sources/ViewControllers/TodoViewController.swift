//
//  TodoViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

import SwipeCellKit

final class TodoViewController: UIViewController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var addButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        return item
    }()
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .none
        view.allowsSelection = false
        view.register(TodoCell.self, forCellReuseIdentifier: "cell")

        view.contentInset.bottom = 49
        view.scrollIndicatorInsets.bottom = 49
        return view
    }()
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Emtpy Todo"
        return label
    }()

    // MARK: - Private

    private let analytics: AppAnalytics

    private let deleteEvent = PublishRelay<IndexPath>()

    private lazy var dataSource: RxTableViewSectionedReloadDataSource<TodoSection> = {
        let dataSource = RxTableViewSectionedReloadDataSource<TodoSection>(configureCell: { [weak self] (_, tableView, _, item) in
            switch item {
            case .row(let reactor):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TodoCell else {
                    return TodoCell()
                }
                cell.delegate = self
                cell.reactor = reactor

                return cell
            }
        })
        return dataSource
    }()

    private func setupConstraints() {
        tableView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(-20)
        }
    }

    // MARK: - Public

    func bind(reactor: TodoViewReactor) {
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)

        /// State
        reactor.state.map { $0.sections }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        reactor.state.map { $0.sections.first?.items.isNotEmpty ?? false }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)

        /// Action
        deleteEvent
            .map { [weak self] indexPath -> String? in
                guard let cell = self?.tableView.cellForRow(at: indexPath) as? TodoCell else { return nil }
                return cell.reactor?.currentState.id
            }
            .filterNil()
            .map { Reactor.Action.delete(id: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        addButtonItem.rx.tap
            .do(onNext: { [weak self] () in
                self?.analytics.log(.todoAddTapped)
            })
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] () in
                guard let ss = self else { return }
                let viewController = ss.Inject(AddTodoViewController.self)
                ss.present(UINavigationController(rootViewController: viewController), animated: true)
            })
            .disposed(by: disposeBag)

        rx.viewDidAppear
            .take(1)
            .map { _ in Reactor.Action.initial }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.title = "Todo"
        navigationItem.rightBarButtonItem = addButtonItem

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        setupConstraints()
    }

    // MARK: - Lifecycle

    required init(_ reactor: TodoViewReactor, _ analytics: AppAnalytics) {
        defer { self.reactor = reactor }
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
extension TodoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}
extension TodoViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            self?.deleteEvent.accept(indexPath)
        }
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
}
