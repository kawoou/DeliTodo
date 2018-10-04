//
//  RxSchedulerConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 06/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import RxSwift

final class RxSchedulerConfiguration: Configuration {

    let realmScheduler = Config(SchedulerType.self, qualifier: "realm") {
        return MainScheduler.asyncInstance
    }
    let syncScheduler = Config(SchedulerType.self, qualifier: "sync") {
        return SerialDispatchQueueScheduler(internalSerialQueueName: "io.kawoou.DeliTodo.sync")
    }

}
