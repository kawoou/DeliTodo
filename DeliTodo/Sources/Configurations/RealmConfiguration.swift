//
//  RealmConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Foundation

import Deli
import RealmSwift

final class RealmConfiguration: Configuration {
    
    // MARK: - Constant
    
    private struct Constant {
        static let schemeVersion: UInt64 = 1
    }
    
    let database = Config(Realm.self, scope: .always) {
        let realmPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
//        try? FileManager.default.removeItem(
//            at: URL(fileURLWithPath: realmPath).appendingPathComponent("DeliTodo.realm")
//        )

        let configuration = Realm.Configuration(
            fileURL: URL(fileURLWithPath: realmPath).appendingPathComponent("DeliTodo.realm"),
            readOnly: false,
            schemaVersion: Constant.schemeVersion,
            migrationBlock: { (migration, oldSchemeVersion) in
                // TODO: Writing after...
            }
        )
        Realm.Configuration.defaultConfiguration = configuration

        return try! Realm()
    }
    
}
