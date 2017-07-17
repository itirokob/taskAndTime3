//
//  Cache.swift
//  gg-lean
//
//  Created by Gustavo Avena on 12/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

// TODO: target memebership

protocol CacheObserver {
    func newData() // Should be called in the main thread, because they're UI related.
    func removeFromObservers()
}

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
    public var observers: [CacheObserver]
    
    private override init() {
        self.tasks = [Task]()
        self.allTasks = [Task]()
        self.observers = [CacheObserver]()
    }
    
    // Notifies observers that the sessions were updated.
    private func notifiyObservers() {
        
        for obs in self.observers {
            OperationQueue.main.addOperation({
                obs.newData()
            })
        }
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
