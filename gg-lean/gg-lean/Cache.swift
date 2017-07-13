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

    private static var sharedCache: Cache = {
        let cache = Cache()
        return cache
    }()
    
    class func shared() -> Cache {
        print("sharedCache tasks: \(sharedCache.tasks)")
        
        return sharedCache
    }
    
    public var tasks: [Task]
    
    private override init() {
        self.tasks = [Task]()
    }
    


}
