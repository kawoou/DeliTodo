//
//  ToastView.swift
//  DeliTodo
//
//  Created by Kawoou on 08/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import Deli
import RxSwift

final class ToastPayload: Payload {
    let toast: Toast

    required init(with argument: (Toast)) {
        self.toast = argument
    }
}

final class ToastView: UIView, AutowiredFactory {

    // MARK: - Deli

    var scope: Scope = .prototype

    // MARK: - Public

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    // MARK: - Private

    private let toast: Toast

    private func setupConstraints() {
        label.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(12)
            maker.top.bottom.equalToSuperview().inset(8)
        }
    }

    // MARK: - Public

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = label.sizeThatFits(
            CGSize(width: size.width - 24, height: size.height)
        )
        return CGSize(
            width: size.width + 24,
            height: size.height + 16
        )
    }

    // MARK: - Lifecycle

    required init(payload: ToastPayload) {
        toast = payload.toast

        super.init(frame: .zero)

        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        clipsToBounds = true
        layer.cornerRadius = 6

        addSubview(label)
        label.text = toast.message

        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
