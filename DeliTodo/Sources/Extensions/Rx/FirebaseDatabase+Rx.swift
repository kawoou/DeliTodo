//
//  FirebaseDatabase+Rx.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import FirebaseDatabase
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element == DataSnapshot {
    func checkExist(_ isExist: Bool = true, throwError: Error) -> Single<DataSnapshot> {
        return flatMap { snapshot in
            guard snapshot.exists() == isExist else { throw throwError }
            return .just(snapshot)
        }
    }
    func checkChildren(_ hasChildren: Bool = true, throwError: Error) -> Single<DataSnapshot> {
        return flatMap { snapshot in
            guard snapshot.hasChildren() == hasChildren else { throw throwError }
            return .just(snapshot)
        }
    }
}

extension Reactive where Base: DatabaseReference {
    func observe(of type: DataEventType) -> Observable<DataSnapshot> {
        return .create { [base] observer in
            let token = base.observe(type, with: {
                observer.onNext($0)
            }, withCancel: {
                observer.onError($0)
            })

            return Disposables.create {
                base.removeObserver(withHandle: token)
            }
        }
    }
    func observeSingleEvent(of type: DataEventType) -> Single<DataSnapshot> {
        return .create { [base] observer in
            base.observeSingleEvent(of: type, with: {
                observer(.success($0))
            }, withCancel: {
                observer(.error($0))
            })
            
            return Disposables.create()
        }
    }
}
