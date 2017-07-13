//
//  Cache.swift
//  gg-lean
//
//  Created by Gustavo Avena on 12/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

// TODO: target memebership

class Cache: NSObject {
    private let manager = DataBaseManager.shared

    private static var sharedCache: Cache = {
        let cache = Cache()
        return cache
    }()
    
    class func shared() -> Cache {        
        return sharedCache
    }
    
    public var tasks: [Task]
    public var allTasks: [Task]
    
    private override init() {
        self.tasks = [Task]()
        self.allTasks = [Task]()
    }
    
    //Loads all the active tasks from the dataBase
    public func updateTasks(active: Bool = true, completionHandler: @escaping ([Task]) -> Void) {
        manager.getTasks(active: active) { (tasks) in
            if active {
                Cache.shared().tasks = tasks
            } else {
                Cache.shared().allTasks = tasks
            }
            completionHandler(tasks)
        }
    }

    


}
