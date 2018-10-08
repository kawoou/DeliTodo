//
//  MockAuthService.swift
//  DeliTodoTests
//
//  Created by Kawoou on 08/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import RxSwift

@testable import DeliTodo

final class MockAuthService: AuthService {

    // MARK: - Expect

    var expectedObserveUser: BehaviorSubject<User?> = BehaviorSubject(value: nil)
    var expectedCurrentUser: User? = nil
    var expectedSignUp: Single<User> = .error(MockError.notImplementated)
    var expectedLogin: Single<User> = .error(MockError.notImplementated)
    var expectedLogout: Single<Void> = .error(MockError.notImplementated)

    var isSignUpCalled: Bool = false
    var isLoginCalled: Bool = false
    var isLogoutCalled: Bool = false

    var numberOfSignUpCalled: Int = 0
    var numberOfLoginCalled: Int = 0
    var numberOfLogoutCalled: Int = 0

    // MARK: - Protocol

    func observeUser() -> Observable<User?> {
        return expectedObserveUser
    }
    func currentUser() -> User? {
        return expectedCurrentUser
    }

    func signUp(credential: Credential, user: User) -> Single<User> {
        isSignUpCalled = true
        numberOfSignUpCalled += 1
        return expectedSignUp
    }
    func login(credential: Credential) -> Single<User> {
        isLoginCalled = true
        numberOfLoginCalled += 1
        return expectedLogin
    }
    func logout() -> Single<Void> {
        isLogoutCalled = true
        numberOfLogoutCalled += 1
        return expectedLogout
    }

}
