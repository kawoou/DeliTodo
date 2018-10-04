//
//  MoreSection.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxDataSources

enum MoreSection {
    case items([MoreItem], title: String)
}
extension MoreSection: SectionModelType {
    var items: [MoreItem] {
        switch self {
        case let .items(items, _):
            return items
        }
    }

    init(original: MoreSection, items: [MoreItem]) {
        switch original {
        case .items:
            self = .items(items, title: "")
        }
    }
}

enum MoreItem {
    case row(MoreCellReactor)
}
