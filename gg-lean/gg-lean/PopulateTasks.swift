//
//  PopulateTasks.swift
//  gg-lean
//
//  Created by Gustavo Avena on 17/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CloudKit

class PopulateTasks: NSObject {
    
    private var startDates: [Date] = [Date]()
    let SESSIONS_NUMBER = 10
    
    func populateTasks() {
        let gym = Task(name: "Gym", isSubtask: 0, id: UUID().uuidString, finishedSessionTime: 0)
        let study = Task(name: "Study", isSubtask: 0, id: UUID().uuidString, finishedSessionTime: 0)
        let soccer = Task(name: "Soccer", isSubtask: 0, id: UUID().uuidString, finishedSessionTime: 0)
        let calculus = Task(name: "Calculus", isSubtask: 0, id: UUID().uuidString, finishedSessionTime: 0)
        let sleep = Task(name: "Sleep", isSubtask: 0, id: UUID().uuidString, finishedSessionTime: 0)
        
        let tasks: [Task] = [gym, study, soccer, calculus, sleep]
        
        
        populatesStartDates()
        
        let sessions = createTaskSessions()
        
        for session in sessions {
            DataBaseManager.shared.addTimeCount(session: session, completionHandler: {(recordID) in })
        }

        for i in 0...sessions.count {
            tasks[i % tasks.count].sessions.append(sessions[i])
        }
        
        for task in tasks {
            DataBaseManager.shared.saveTask(task: task, completion: { (task2, error) in
                
                guard error == nil, let _ = task2 else {
                    print("Error in adding mock task: \(String(describing: error))")
                    return
                }
                
                print("Saved mock task to CK.")
            })
        }

        
        print("Mock script finished")
        
    }
    
    func saveSession(session: TaskSession) {
        let newTimeCount = CKRecord(recordType: "Session", recordID: session.recordID!)
        

        newTimeCount.setObject(session.startDate as CKRecordValue, forKey: "startDate")
        newTimeCount.setObject(session.stopDate as CKRecordValue?, forKey: "stopDate")
        newTimeCount.setObject(session.durationInSeconds as CKRecordValue, forKey: "duration")
        
        DataBaseManager.shared.publicData.save(newTimeCount, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Error addTimeCount --->" + (error!.localizedDescription))
            } else {
                print("Saved mock session to CK")
            }
        })

    }
    
    func randomValue(_ min: Int, _ max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max)))
    }
    
    func setupDay(daysToRemove days: Int, hours: Int) -> Date {
        let day = Calendar.current.date(byAdding: .day, value: (-1)*days, to: Date())
        return Calendar.current.date(bySetting: .hour, value: hours, of: day!)!
    }
    
    func populatesStartDates() {
        for _ in 0...SESSIONS_NUMBER {
            startDates.append(setupDay(daysToRemove: (-1 * randomValue(1, 10)), hours: randomValue(8, 19)))
        }
    }
    
    func createTaskSessions() -> [TaskSession] {
        var sessions = [TaskSession]()
        
        for date in startDates {
            let duration = randomValue(45, 60 * 200)
            let stopDate = Calendar.current.date(byAdding: .second, value: duration, to: date)
            let recordID = CKRecordID(recordName: UUID().uuidString)
            sessions.append(TaskSession(startDate: date, stopDate: stopDate, durationInSeconds: duration, recordID: recordID))

        }
        return sessions
    }

}
