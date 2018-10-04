//
//  FirebaseAuth+Rx.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import FirebaseAuth
import RxSwift

enum FirebaseAuthError: Error {
    case userNotFound
    case failedToCreateUser
}

extension Reactive where Base: UserProfileChangeRequest {
    func commitChanges() -> Single<Void> {
        return .create { [base] observer in
            base.commitChanges { error in
                if let error = error {
                    observer(.error(error))
                } else {
                    observer(.success(Void()))
                }
            }
            return Disposables.create()
        }
    }
}

extension Reactive where Base: Auth {
    func createUser(withEmail email: String, password: String) -> Single<AuthDataResult> {
        return .create { [base] observer in
            base.createUser(withEmail: email, password: password) { (result, error) in
                guard let result = result else {
                    observer(.error(FirebaseAuthError.failedToCreateUser))
                    return
                }
                if let error = error {
                    observer(.error(error))
                } else {
                    observer(.success(result))
                }
            }
            return Disposables.create()
        }
    }
    func signIn(withEmail email: String, password: String) -> Single<AuthDataResult> {
        return .create { [base] observer in
            base.signIn(withEmail: email, password: password) { (result, error) in
                guard let result = result else {
                    observer(.error(FirebaseAuthError.userNotFound))
                    return
                }
                if let error = error {
                    observer(.error(error))
                } else {
                    observer(.success(result))
                }
            }

            return Disposables.create()
        }
    }
    func signOut() -> Single<Void> {
        return .create { [base] observer in
            do {
                try base.signOut()
                observer(.success(Void()))
            } catch let error {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }
}
