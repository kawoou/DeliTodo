//
//  MainNavigationViewController.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import ReactorKit
import RxCocoa
import RxSwift
import SnapKit

final class MainNavigationViewController: UINavigationController, View, Autowired {

    // MARK: - Deli

    var scope: Scope = .weak

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var tabBar: UITabBar = {
        let tabBar = UITabBar()
        tabBar.tintColor = UIColor(red: 0.118, green: 0.235, blue: 0.447, alpha: 1)
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowOpacity = 0.1
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor.white
        tabBar.barStyle = .blackOpaque
        return tabBar
    }()

    // MARK: - Private

    private let analytics: AppAnalytics

    private static func makeTabItem(_ tab: MainNavigationViewReactor.Tab) -> UITabBarItem {
        let item: UITabBarItem
        switch tab {
        case .todo:
            item = UITabBarItem(title: nil, image: Asset.tabTodoNormal.image, selectedImage: Asset.tabTodoSelected.image)
        case .more:
            item = UITabBarItem(title: nil, image: Asset.tabMoreNormal.image, selectedImage: Asset.tabMoreSelected.image)
        }
        item.tag = tab.rawValue

        return item
    }
    private func switchViewController(_ oldTab: MainNavigationViewReactor.Tab, _ newTab: MainNavigationViewReactor.Tab) {
        let newController: UIViewController

        /// Push view controller
        switch newTab {
        case .todo:
            newController = Inject(TodoViewController.self)
        case .more:
            newController = Inject(MoreViewController.self)
        }

        /// Pop and push view controller
        let oldController = viewControllers.first
        viewControllers = [newController]

        /// Set swap animations
        guard let safeOldController = oldController else { return }

        newController.view.layer.removeAllAnimations()
        newController.view.transform = CGAffineTransform(
            translationX: (oldTab.rawValue < newTab.rawValue ? 100 : -100),
            y: 0
        )

        safeOldController.view.layer.removeAllAnimations()
        safeOldController.view.transform = .identity
        safeOldController.view.alpha = 1

        /// Start Transition
        safeOldController.removeFromParent()
        safeOldController.view.removeFromSuperview()
        view.insertSubview(safeOldController.view, belowSubview: navigationBar)

        UIView.animate(
            withDuration: 0.2,
            animations: {
                newController.view.transform = .identity
                newController.view.alpha = 1

                safeOldController.view.transform = CGAffineTransform(
                    translationX: (oldTab.rawValue < newTab.rawValue ? -100 : 100),
                    y: 0
                )
                safeOldController.view.alpha = 0
            }, completion: { isComplete in
                guard isComplete == true else { return }

                safeOldController.view.removeFromSuperview()
                safeOldController.view.transform = .identity
                safeOldController.view.alpha = 1
            }
        )
    }

    private func setupTabBar() {
        let items = MainNavigationViewReactor.Tab.allCases
            .map(MainNavigationViewController.makeTabItem)

        tabBar.items = items
        tabBar.selectedItem = items[0]
    }
    private func setupConstraints() {
        tabBar.snp.makeConstraints { maker in
            maker.leading.trailing.bottom.equalToSuperview()
            maker.height.equalTo(49)
        }
    }

    // MARK: - Public

    func bind(reactor: MainNavigationViewReactor) {
        /// State
        /// If the selected tab is clicked, call popToRootViewController().
        reactor.state
            .map { $0.currentTab }
            .scan((Reactor.Tab.todo, Reactor.Tab.todo)) { state, newTab in
                return (state.1, newTab)
            }
            .filter { $0.0 == $0.1 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.popToRootViewController(animated: true)
            })
            .disposed(by: disposeBag)

        /// If the unselected tab is clicked, play swap transition.
        reactor.state
            .map { $0.currentTab }
            .distinctUntilChanged()
            .scan((Reactor.Tab.todo, Reactor.Tab.todo)) { state, newTab in
                return (state.1, newTab)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.switchViewController(state.0, state.1)
            })
            .disposed(by: disposeBag)

        /// Action
        let oldIndex = BehaviorRelay(value: MainNavigationViewReactor.Tab.todo)

        tabBar.rx.didSelectItem
            .map { $0.tag }
            .do(onNext: { [weak self] index in
                self?.analytics.log(.mainTabChange(index: index))
            })
            .map { MainNavigationViewReactor.Tab(rawValue: $0) }
            .filterNil()
            .do(onNext: {
                oldIndex.accept($0)
            })
            .map { Reactor.Action.changeTab($0) }
            .subscribe(reactor.action)
            .disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = false

        view.backgroundColor = .white
        view.addSubview(tabBar)

        setupTabBar()
        setupConstraints()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        tabBar.snp.updateConstraints { maker in
            maker.height.equalTo(view.safeAreaInsets.bottom + 49.0)
        }
    }

    // MARK: - Lifecycle

    required init(_ reactor: MainNavigationViewReactor, _ analytics: AppAnalytics) {
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
