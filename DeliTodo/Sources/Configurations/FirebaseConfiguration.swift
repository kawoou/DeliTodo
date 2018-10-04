//
//  FirebaseConfiguration.swift
//  DeliTodo
//
//  Created by Kawoou on 03/10/2018.
//  Copyright © 2018 Kawoou. All rights reserved.
//

import Deli
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

final class FirebaseConfiguration: Configuration {
    
    let firebase = Config(FirebaseApp.self, scope: .always) {
        FirebaseCore.FirebaseConfiguration.shared.setLoggerLevel(.warning)
        FirebaseApp.configure()
        return FirebaseApp.app()!
    }

    let auth = Config(Auth.self, FirebaseApp.self) { app in
        return Auth.auth(app: app)
    }
    let database = Config(Database.self, FirebaseApp.self) { app in
        return Database.database(app: app)
    }
    
    let todoTable = Config(DatabaseReference.self, Database.self, qualifier: "todo", scope: .weak) { database in
        return database.reference().child("todo")
    }
    let userTable = Config(DatabaseReference.self, Database.self, qualifier: "user", scope: .weak) { database in
        return database.reference().child("user")
    }
    
}
