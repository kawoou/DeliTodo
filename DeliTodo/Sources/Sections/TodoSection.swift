//
//  TodoSection.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxDataSources

enum TodoSection {
    case items([TodoItem])
}
extension TodoSection: SectionModelType {
    var items: [TodoItem] {
        switch self {
        case let .items(items):
            return items
        }
    }

    init(original: TodoSection, items: [TodoItem]) {
        switch original {
        case .items:
            self = .items(items)
        }
    }
}

enum TodoItem {
    case row(TodoCellReactor)
}
