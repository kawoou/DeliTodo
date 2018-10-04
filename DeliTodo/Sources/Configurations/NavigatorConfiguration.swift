//
//  NavigatorConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 2018. 10. 4..
//  Copyright © 2018년 Kawoou. All rights reserved.
//

import Deli
import DeepLinkKit

final class NavigatorConfiguration: Configuration {

    let router = Config(DPLDeepLinkRouter.self, Navigator.self) { navigator in
        let router = DPLDeepLinkRouter()

        router.register("/main") { _ in
            navigator.navigate(to: .main)
        }

        return router
    }

}
