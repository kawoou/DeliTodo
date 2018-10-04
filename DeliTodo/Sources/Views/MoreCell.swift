//
//  MoreCell.swift
//  DeliTodo
//
//  Created by Kawoou on 07/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import ReactorKit
import RxSwift

final class MoreCell: UITableViewCell, View {

    // MARK: - Property

    var disposeBag = DisposeBag()

    // MARK: - Public

    func bind(reactor: MoreCellReactor) {
        /// State
        reactor.state.map { $0.title }
            .bind(to: textLabel!.rx.text)
            .disposed(by: disposeBag)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
