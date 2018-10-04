//
//  NavigatorImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Deli

final class NavigatorImpl: Navigator, Autowired {

    let window: UIWindow

    func navigate(to target: NavigatorTarget) {
        switch target {
        case .splash:
            window.rootViewController = Inject(SplashViewController.self)
        case .login:
            window.rootViewController = Inject(LoginViewController.self)
        case .main:
            window.rootViewController = Inject(MainNavigationViewController.self)
        }
    }

    required init(_ window: UIWindow) {
        self.window = window

        window.makeKeyAndVisible()
    }
}
