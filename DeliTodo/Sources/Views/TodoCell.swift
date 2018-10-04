//
//  TodoCell.swift
//  DeliTodo
//
//  Created by Kawoou on 05/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import SwipeCellKit

final class TodoCell: SwipeTableViewCell, View {

    // MARK: - Property

    override var alpha: CGFloat {
        get { return super.alpha }
        set { super.alpha = 1.0 }
    }

    var disposeBag = DisposeBag()

    // MARK: - Interface

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.905882353, alpha: 1)
        return view
    }()
    private lazy var circleView: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.118, green: 0.235, blue: 0.447, alpha: 1).cgColor
        view.clipsToBounds = true
        return view
    }()
    private lazy var innerCircleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = UIColor(red: 0.118, green: 0.235, blue: 0.447, alpha: 1)
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .black
        return label
    }()
    private lazy var sliceLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.118, green: 0.235, blue: 0.447, alpha: 1)
        view.alpha = 0
        return view
    }()

    // MARK: - Private

    private var sliceLineMaxTrailingConstraint: Constraint!

    private var cellDisposeBag = DisposeBag()

    private func setupConstraints() {
        lineView.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().inset(10)
            maker.bottom.equalToSuperview()
            maker.height.equalTo(1)
        }
        circleView.snp.makeConstraints { maker in
            maker.size.equalTo(16)
            maker.leading.equalTo(18)
            maker.centerY.equalToSuperview()
        }
        innerCircleView.snp.makeConstraints { maker in
            maker.size.equalTo(12)
            maker.center.equalTo(circleView)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.leading.equalTo(circleView.snp.trailing).offset(14)
            maker.trailing.equalToSuperview().inset(10)
            maker.top.bottom.equalToSuperview()
        }
        sliceLineView.snp.makeConstraints { maker in
            maker.height.equalTo(1)
            maker.centerY.equalToSuperview()
            maker.leading.equalTo(titleLabel.snp.leading)
            maker.trailing.equalTo(titleLabel.snp.leading).priority(.high)
            sliceLineMaxTrailingConstraint = maker.trailing.equalToSuperview().inset(10).constraint
        }
    }

    private func updateSliceLine(_ isChecked: Bool) {
        if isChecked {
            sliceLineView.alpha = 1
            sliceLineMaxTrailingConstraint.activate()
        } else {
            sliceLineView.alpha = 0
            sliceLineMaxTrailingConstraint.deactivate()
        }
        layoutIfNeeded()
    }

    // MARK: - Public

    func bind(reactor: TodoCellReactor) {
        /// State
        reactor.state.map { $0.title }
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isPressing }
            .map { $0 ? 0.5 : 1 }
            .bind(to: innerCircleView.rx.alpha)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isChecked || $0.isPressing }
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: innerCircleView.rx.isHidden)
            .disposed(by: disposeBag)

        reactor.state.map { $0.isChecked }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isChecked in
                self?.updateSliceLine(isChecked)
            })
            .disposed(by: disposeBag)

        /// Action
        Observable
            .merge(
                circleView.rx.controlEvent(.touchDown)
                    .map { Reactor.Action.setPressing(true) },
                circleView.rx.controlEvent(.touchUpInside)
                    .map { Reactor.Action.setPressing(false) },
                circleView.rx.controlEvent(.touchUpOutside)
                    .map { Reactor.Action.setPressing(false) }
            )
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        circleView.rx.tap
            .flatMapLatest { reactor.state.take(1) }
            .map { $0.isChecked }
            .map { Reactor.Action.setChecked(!$0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .white

        contentView.addSubview(lineView)
        contentView.addSubview(circleView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(innerCircleView)
        contentView.addSubview(sliceLineView)

        setupConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        logger.debug("deinit: \(type(of: self))")
    }
}
