//
//  FabricConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 06/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Crashlytics
import Deli
import Fabric

final class FabricConfiguration: Configuration {

    let fabric = Config(Fabric.self, scope: .always) {
        return Fabric.with([Crashlytics.self])
    }

}
