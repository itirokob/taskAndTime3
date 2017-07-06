//
//  Task.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CloudKit

struct TaskSession {
    var startDate:Date
    var durationInSeconds:Int
    var recordID:CKRecordID?
}

class Task: NSObject {
    //No vetor sessions, a última posição será a sessão atual
    var sessions: [TaskSession] = [TaskSession]()
    public var name:String
    public var isSubtask:Int
    public var tasksDates:[Date]
    public var tasksTimes:[Int]
    private var totalTime:Int //Tem que ser recalculado toda vez
    public var isActive:Int
    public var id:String
    public var isRunning:Bool = false
    public var currPlayID:String = ""
    
    public var recordName:String?
    
    init(name:String, isSubtask:Int, tasksDates:[Date], tasksTimes:[Int], totalTime: Int, isActive:Int, id:String){
        self.name = name
        self.isSubtask = isSubtask
        self.tasksDates = tasksDates
        self.tasksTimes = tasksTimes
        self.totalTime = totalTime
        self.isActive = isActive
        self.id = id
    }
    
    func setSessions(sessionsArray:[TaskSession]){
        self.sessions = sessionsArray
    }
    
    /// The updateTotalTime function sums all the session's durations into totalTime
    ///
    /// - Returns: the totalTime
    func updateTotalTime() -> Int{
        var counter:Int = 0
        if(sessions.count > 0){
            for i in 0...(sessions.count - 1){
                counter += sessions[i].durationInSeconds
            }
        }
        return counter
    }
    
    
    /// The startSession function starts a session
    ///
    /// - Parameter startDate: task's startDate
    func startSession(startDate:Date){
        sessions.append(TaskSession(startDate: startDate, durationInSeconds: 0, recordID:nil))
    }
    
    func updateSessionDuration(){
        var currSession = sessions.count - 1
        if(currSession < 0){
            currSession = 0
        }
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: sessions[currSession].startDate, to: Date())

        sessions[sessions.count - 1].durationInSeconds = components.second!
                
        //Feels like migué
        self.totalTime += 1
    }
    
    func getTotalTime()->Int{
        return totalTime
    }
    
    func getSessionsSize() -> Int{
        return sessions.count
    }
    
    func getTimeString() -> String{
        
        let minutes :Int = totalTime / 60
        let seconds :Int = totalTime - 60*minutes
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
}
