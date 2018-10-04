//
//  AnalyticsConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import Umbrella

typealias AppAnalytics = Analytics<AnalyticsEvent>

final class AnalyticsConfiguration: Configuration {

    let analytics = Config(AppAnalytics.self) {
        let analytics = AppAnalytics()
        analytics.register(provider: FirebaseProvider())
        return analytics
    }

}
