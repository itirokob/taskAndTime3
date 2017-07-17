//
//  PopulateTasks.swift
//  gg-lean
//
//  Created by Gustavo Avena on 17/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import CloudKit

/**
 To create mock Task and TaskSession objects, just execute the populateTasks() method **once**.
 To delete all records, call the deleteAllRecords() method (you may need to execute it twice due to the DB dependecies and relations).
 */
class PopulateTasks: NSObject {
    
    private var startDates: [Date] = [Date]()
    let SESSIONS_NUMBER = 200
    let MAX_MINUTES_SESSION = 60
    
    func populateTasks() {
        let taskNames = ["Gym", "Study", "Soccer", "Calculus", "Sleep", "Piano", "Literature", "Work on Clic", "History paper"]
        

        var tasks = [Task]()
        
        for name in taskNames {
            tasks.append(Task(name: name, isSubtask: 0, id: UUID().uuidString, finishedSessionTime: 0))
        }
        
        print("Running mock script")
        
        populatesStartDates()
        
        let sessions = createTaskSessions()
        
        for i in 0..<sessions.count {
            tasks[i % tasks.count].sessions.append(sessions[i])
            tasks[i % tasks.count].finishedSessionTime += sessions[i].durationInSeconds
        }
        
        for session in sessions {
            saveSession(session: session)
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
                print("Error saving mock session: " + (error!.localizedDescription))
            } else {
//                print("Saved mock session to CK")
            }
        })
        
        print("Saved mock sessions to CK")

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
            startDates.append(setupDay(daysToRemove: randomValue(1, 10), hours: randomValue(0, 12)))
        }
    }
    
    func createTaskSessions() -> [TaskSession] {
        var sessions = [TaskSession]()
        
        for date in startDates {
            let duration = randomValue(45, 60 * MAX_MINUTES_SESSION)
            let stopDate = Calendar.current.date(byAdding: .second, value: duration, to: date)
            let recordID = CKRecordID(recordName: UUID().uuidString)
            sessions.append(TaskSession(startDate: date, stopDate: stopDate, durationInSeconds: duration, recordID: recordID))

        }
        return sessions
    }
    
    func deleteAllRecords() {
        deleteAllRecords(tasks: true)
        deleteAllRecords(tasks: false)
    }
    
    func deleteAllRecords(tasks: Bool = true) {
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: tasks ? "Task" : "Session", predicate:predicate)
        
        DataBaseManager.shared.publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil || results == nil {
                print("Error ", String(describing: error))
            } else {
                print(results!.count)
                for record in results! {
                    DataBaseManager.shared.publicData.delete(withRecordID: record.recordID, completionHandler: {
                        (record, error) in
                        guard error == nil else {
                            print("Erro deletando record no CK.")
                            return
                        }
                        
                    })
                }
                print("Todos os \(tasks ? "tasks" : "sessions") deletados")
                
            }
        }
    }

}
