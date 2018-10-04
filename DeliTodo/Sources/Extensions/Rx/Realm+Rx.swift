//
//  Realm+Rx.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RealmSwift
import RxSwift

extension Realm: ReactiveCompatible {}
extension Reactive where Base: Realm {
    func object<Element, KeyType>(of type: Element.Type, forPrimaryKey primaryKey: KeyType) -> Single<Element?> where Element: Object {
        return .create { [base] observer in
            let object = base.object(ofType: type, forPrimaryKey: primaryKey)
            observer(.success(object))
            
            return Disposables.create()
        }
    }
    func objects<Element>(of type: Element.Type) -> Single<Results<Element>> where Element: Object {
        return .create { [base] observer in
            let objects = base.objects(type)
            observer(.success(objects))
            
            return Disposables.create()
        }
    }

    func observe<Element, KeyType>(of type: Element.Type, forPrimaryKey primaryKey: KeyType) -> Observable<Element?> where Element: Object {
        return .create { [base] observer in
            let object = base.object(ofType: type, forPrimaryKey: primaryKey)
            observer.onNext(object)

            let token = object?
                .observe { result in
                    switch result {
                    case .change(let changes):
                        changes.forEach { change in
                            guard let value = change.newValue as? Element else {
                                observer.onNext(nil)
                                observer.onCompleted()
                                return
                            }
                            observer.onNext(value)
                        }

                    case .deleted:
                        observer.onNext(nil)
                        observer.onCompleted()

                    case .error(let error):
                        observer.onError(error)
                    }
                }

            return Disposables.create {
                token?.invalidate()
            }
        }
    }
    func observes<Element>(of type: Element.Type) -> Observable<[Element]> where Element: Object {
        return .create { [base] observer in
            let token = base.objects(type)
                .observe { result in
                    switch result {
                    case let .initial(results):
                        observer.onNext(Array(results))

                    case let .update(results, _, _, _):
                        observer.onNext(Array(results))

                    case let .error(error):
                        observer.onError(error)
                    }
                }

            return Disposables.create {
                token.invalidate()
            }
        }
    }
}
