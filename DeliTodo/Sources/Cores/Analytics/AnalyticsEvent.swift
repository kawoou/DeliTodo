//
//  AnalyticsEvent.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Umbrella

enum AnalyticsEvent {
    /// Login Screen
    case loginDo
    case login(isSuccess: Bool)
    case loginUnknownError(message: String)

    /// Sign Up Screen
    case signUpDo
    case signUp(isSuccess: Bool)
    case signUpUnknownError(message: String)

    /// Main Screen
    case mainTabChange(index: Int)

    /// Todo Screen
    case todoAddTapped

    /// More Screen
    case moreLogout
}

extension AnalyticsEvent: EventType {
    func name(for provider: ProviderType) -> String? {
        switch self {
        case .loginDo:
            return "login_do"
        case .login:
            return "login"
        case .loginUnknownError:
            return "login_unknown_error"
        case .signUpDo:
            return "signup_do"
        case .signUp:
            return "signup"
        case .signUpUnknownError:
            return "signup_unknown_error"
        case .mainTabChange:
            return "main_tab_change"
        case .todoAddTapped:
            return "todo_add_tap"
        case .moreLogout:
            return "more_logout"
        }
    }
    func parameters(for provider: ProviderType) -> [String: Any]? {
        switch self {
        case .loginDo:
            return nil

        case let .login(isSuccess):
            return ["success": isSuccess]

        case let .loginUnknownError(message):
            return ["message": message]

        case .signUpDo:
            return nil

        case let .signUp(isSuccess):
            return ["success": isSuccess]

        case let .signUpUnknownError(message):
            return ["message": message]

        case let .mainTabChange(index):
            return ["tab_index": index]

        case .todoAddTapped:
            return nil

        case .moreLogout:
            return nil
        }
    }
}
