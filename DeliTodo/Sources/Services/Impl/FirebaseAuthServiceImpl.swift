//
//  FirebaseAuthServiceImpl.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import FirebaseAuth
import RxCocoa
import RxSwift

final class FirebaseAuthServiceImpl: AuthService, Autowired {

    // MARL: - Private

    private let auth: Auth

    private let userRelay = BehaviorRelay<User?>(value: nil)

    // MARK: - Public

    func observeUser() -> Observable<User?> {
        return userRelay.asObservable()
    }
    func currentUser() -> User? {
        return userRelay.value
    }
    func signUp(credential: Credential, user: User) -> Single<User> {
        return auth.rx.createUser(withEmail: credential.email, password: credential.password)
            .flatMap { callback -> Single<User> in
                let request = callback.user.createProfileChangeRequest()
                request.displayName = user.name

                return request.rx.commitChanges()
                    .map {
                        User(
                            id: callback.user.uid,
                            email: credential.email,
                            name: user.name
                        )
                    }
            }
    }
    func login(credential: Credential) -> Single<User> {
        return auth.rx.signIn(withEmail: credential.email, password: credential.password)
            .map {
                User(
                    id: $0.user.uid,
                    email: credential.email,
                    name: $0.user.displayName ?? ""
                )
            }
            .do(onSuccess: { [weak self] user in
                self?.userRelay.accept(user)
            })
    }
    func logout() -> Single<Void> {
        return auth.rx.signOut()
            .do(onSuccess: { [weak self] () in
                self?.userRelay.accept(nil)
            })
    }

    // MARK: - Lifecycle
    
    required init(_ auth: Auth) {
        self.auth = auth

        if let user = auth.currentUser {
            userRelay.accept(
                User(
                    id: user.uid,
                    email: user.email ?? "",
                    name: user.displayName ?? ""
                )
            )
        }
    }
    
}
