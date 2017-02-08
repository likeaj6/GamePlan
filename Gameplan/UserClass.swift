//
//  Database.swift
//  flare.io
//
//  Created by Jason Jin on 10/6/16.
//  Copyright © 2016 Jason Jin. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    let username: String
    let ref: FIRDatabaseReference?
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
        username = authData.displayName!
        ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        self.uid = snapshot.key
        //self.uid = snapshotValue["id"] as! String
        self.email = snapshotValue["email"] as! String
        self.username = snapshotValue["username"] as! String
        //self.firstName
        self.ref = snapshot.ref
    }

    init(uid: String, email: String, username: String) {
        self.uid = uid
        self.email = email
        self.username = username
        ref = nil
    }
}


