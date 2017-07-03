//
//  Task.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class Task: NSObject {
    public var name:String
    public var isSubtask:Int
    public var tasksDates:[Date]
    public var tasksTimes:[Int]
    public var totalTime:Int
    public var isActive:Int
    public var id:String
    public var playPauseState:buttonsState = buttonsState.play
    
    init(name:String, isSubtask:Int, tasksDates:[Date], tasksTimes:[Int], totalTime: Int, isActive:Int, id:String){
        self.name = name
        self.isSubtask = isSubtask
        self.tasksDates = tasksDates
        self.tasksTimes = tasksTimes
        self.totalTime = totalTime
        self.isActive = isActive
        self.id = id
    }
}
