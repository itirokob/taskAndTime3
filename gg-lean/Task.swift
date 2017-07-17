//
//  Task.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CloudKit

protocol SessionsObserver {
    func newData() // Should be called in the main thread, because they're UI related.
    func removeFromObservers()
}

struct TaskSession {
    var startDate:Date
    var stopDate: Date?
    var durationInSeconds:Int
    var recordID:CKRecordID?
    
    func getTimeString() -> String {
        var seconds = durationInSeconds
        
        let hours: Int = seconds/3600
        
        let minutes :Int = (seconds % 3600) / 60
        seconds = seconds - (3600 * hours) - (60 * minutes)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}

class Task: NSObject {
    //No vetor sessions, a última posição será a sessão atual
    var sessions: [TaskSession] = [TaskSession]() {
        didSet {
            notifiyObservers()
        }
    }
    var currentSession: TaskSession?
    public var name:String
    public var isSubtask:Int
    public var finishedSessionTime: Int
    public var totalTime:Int {
        get {
            if let currentSession = self.currentSession {
                let interval = Int(DateInterval(start: currentSession.startDate, end: Date()).duration)
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
    
    public var sessionsObservers: [SessionsObserver] = [SessionsObserver]()
    
    init(name:String, isSubtask:Int, isActive:Int = 1, id:String, finishedSessionTime: Int = 0){
        self.name = name
        self.isSubtask = isSubtask
        self.isActive = isActive
        self.id = id
        self.finishedSessionTime = finishedSessionTime
    }
    
    func setSessions(sessionsArray:[TaskSession]){
        self.sessions = sessionsArray
    }
    
    // Notifies observers that the sessions were updated.
    private func notifiyObservers() {
        
        for obs in self.sessionsObservers {
            OperationQueue.main.addOperation({
                obs.newData()
            })
        }
    }

    
    /// The startSession function starts a session
    ///
    /// - Parameter startDate: task's startDate
    func startSession(startDate:Date) -> Bool{
        guard self.currentSession == nil else {
            print("Can't start another session when one is already running!")
            return false
        }
        
        
        self.currentSession = TaskSession(startDate: startDate, stopDate: nil, durationInSeconds: 0, recordID:nil)
        self.isRunning = true
        
        return true
    }
    
    func stopSession() -> TaskSession? {
        guard currentSession != nil else {
            print("no current session to be stopped")
            return nil
        }
        
        
        currentSession!.stopDate = Date()
        updateCurrentSessionDuration()
        
        
        // Add it to the array only after the end, because it's a struct and it's passed by value, not reference. If we add it to the array first and modify it, we won't be updating the one in the the array?
        sessions.append(currentSession!)
        self.finishedSessionTime += currentSession!.durationInSeconds
        let cs = currentSession
        
        self.currentSession = nil
        self.isRunning = false
        
        return cs

    }
    
    func updateCurrentSessionDuration() {
        guard var currentSession = self.currentSession else {
            print("currentSession from task \(self.name) is nil!")
            return
        }
        let components = Calendar.current.dateComponents([.second], from: currentSession.startDate, to: Date())
        
        currentSession.durationInSeconds = components.second ?? 0
        
        self.currentSession = currentSession // update the instance variable
    }

    func getTotalTime()->Int{
        return totalTime
    }
    
    func getSessionsSize() -> Int{
        return sessions.count
    }
    
    func getTimeString(active: Bool = true) -> String{
        var seconds = active ? totalTime : finishedSessionTime
        
        let hours: Int = seconds/3600
        
        let minutes :Int = (seconds % 3600) / 60
        seconds = seconds - (3600 * hours) - (60 * minutes)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
