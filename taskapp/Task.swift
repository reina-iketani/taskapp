//
//  Task.swift
//  taskapp
//
//  Created by Reina Iketani on 2023/06/06.
//

import RealmSwift

class Task: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var title = ""
    
    @Persisted var contents = ""
    
    @Persisted var date = Date()
    
    @Persisted var category = ""
}

