//
//  WindowConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import UIKit

import Deli

final class WindowConfiguration: Configuration {

    let mainWindow = Config(UIWindow.self) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        return window
    }

    let toastWindow = Config(UIWindow.self, ToastViewController.self, qualifier: "toast", scope: .always) { toastViewController in
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = toastViewController
        window.backgroundColor = .clear
        window.windowLevel = .alert
        window.isUserInteractionEnabled = false
        window.isHidden = false
        return window
    }

}
