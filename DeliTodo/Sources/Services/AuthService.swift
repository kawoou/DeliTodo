//
//  AuthService.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxSwift

protocol AuthService {
    func observeUser() -> Observable<User?>
    func currentUser() -> User?

    func signUp(credential: Credential, user: User) -> Single<User>
    func login(credential: Credential) -> Single<User>
    func logout() -> Single<Void>
}
