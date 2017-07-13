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
    var stopDate: Date?
    var durationInSeconds:Int
    var recordID:CKRecordID?
}

class Task: NSObject {
    //No vetor sessions, a última posição será a sessão atual
    var sessions: [TaskSession] = [TaskSession]()
    var currentSession: TaskSession?
    public var name:String
    public var isSubtask:Int
    private var finishedSessionTime: Int
    public var totalTime:Int {
        get {
            
            if let currentSession = self.currentSession {
//                updateCurrentSessionDuration()
                print("startDate: \(currentSession.startDate)")
                let interval = Int(DateInterval(start: currentSession.startDate, end: Date()).duration)
                print(interval)
                return finishedSessionTime + interval
            } else {
                return finishedSessionTime
            }

        }
    }
    public var isActive:Int
    public var id:String
    public var isRunning:Bool = false
    public var currPlayID:String = ""
    
    public var recordName:String?
    
    init(name:String, isSubtask:Int, isActive:Int = 0, id:String, finishedSessionTime: Int){
        self.name = name
        self.isSubtask = isSubtask
//        self.totalTime = totalTime
        self.isActive = isActive
        self.id = id
        self.finishedSessionTime = finishedSessionTime
    }
    
    func setSessions(sessionsArray:[TaskSession]){
        self.sessions = sessionsArray
    }
    

    
    /// The startSession function starts a session
    ///
    /// - Parameter startDate: task's startDate
    func startSession(startDate:Date) -> Bool{
        guard self.currentSession == nil else {
            print("Can't start another session when one is already running1")
            return false
        }
        self.currentSession = TaskSession(startDate: startDate, stopDate: nil, durationInSeconds: 0, recordID:nil)
        
        print("currentSession is now: \(String(describing: self.currentSession))")
        return true
    }
    
    func stopSession() -> TaskSession? {
        guard currentSession != nil else {
            print("no current session to be stopped")
            return nil
        }
        currentSession!.stopDate = Date()
        updateCurrentSessionDuration()
        
        
        if currentSession != nil {
            
            // Add it to the array only after the end, because it's a struct and it's passed by value, not reference. If we add it to the array first and modify it, we won't be updating the one in the the array?
            sessions.append(currentSession!)
            self.finishedSessionTime += currentSession!.durationInSeconds
            let cs = currentSession
            currentSession = nil
            return cs
        } else {
            print("currentSession couldnt be stopped because it's nil after it should have been updated!")
            return nil
        }
    
    }
    
    func updateCurrentSessionDuration() {
        guard var currentSession = self.currentSession else {
            print("currentSession is nil!")
            return
        }
        let components = Calendar.current.dateComponents([.second], from: currentSession.startDate, to: Date())
        
        
        currentSession.durationInSeconds = components.second ?? 0
        
        
        self.currentSession = currentSession // update the instance variable
    }
    
//    func updateSessionDuration(){
//        let currSession = sessions.count > 0 ? sessions.count - 1 : 0
//        
//        
//        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: sessions[currSession].startDate, to: Date())
//
//        sessions[currSession].durationInSeconds = components.second!
//                
//        //Feels like migué
//        self.totalTime += 1
//    }
    
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
