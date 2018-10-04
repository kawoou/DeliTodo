//
//  Toast.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Foundation

struct Toast: Equatable {
    enum Level {
        case normal
        case debug
    }

    let uuid: UUID = UUID()
    let message: String
    let level: Level
    let duration: Int
}
