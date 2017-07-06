//
//  TimeCounter.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/30/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation

class TimeCounter:NSObject {
    public var startDate:Date
    public var endDate:Date
    public var taskID:String
    public var isActive:Bool
    public var id:String
    
    init(taskID:String) {
        self.taskID = taskID
        self.startDate = Date()
        self.endDate = Date()
        self.isActive = true
        self.id = UUID().uuidString
    }
    
    func setStartDate(startDate:Date){
        self.startDate = startDate
    }
    
    func setEndDate(endDate:Date){
        self.endDate = endDate
    }
}
