//
//  Navigator.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

enum NavigatorTarget {
    case splash
    case login
    case main
}

protocol Navigator {
    func navigate(to target: NavigatorTarget)
}
