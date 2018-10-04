//
//  Logger.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import SwiftyBeaver

let logger: SwiftyBeaver.Type = {
    let console = ConsoleDestination()
    let file = FileDestination()
    let cloud = SBPlatformDestination(appID: "2kYemZ", appSecret: "cjw6k6mgrnFkcqjsmncRkq7hwsAgNwor", encryptionKey: "jCzf8zpflXbljxpvwKuvs9utyhpuAgxc")

    console.format = "$DHH:mm:ss$d $L $M"

    $0.addDestination(console)
    $0.addDestination(file)
    $0.addDestination(cloud)
    return $0
}(SwiftyBeaver.self)
