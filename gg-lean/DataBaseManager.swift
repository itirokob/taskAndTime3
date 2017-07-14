//
//  DataBaseManager.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation
import CloudKit

class DataBaseManager : NSObject {
    static let shared = DataBaseManager()
    let publicData = CKContainer(identifier: "iCloud.icloud.br.org.eldorado.bepid.gg-lean.shared-container").publicCloudDatabase
    
    
    //TO DO: ADICIONAR O TIMECOUNTERLIST
    let tasksFields = ["name", "isSubtask", "totalTime", "isActive", "id"]
    
    /// The objectInfoInArray returns a array with the fields of a given Task object
    ///
    /// - Parameter objectTask: Task object with which the fields will form the array
    /// - Returns: a array with the fields from the objectTask object
    func objectInfoInArray (_ objectTask:Task)->[Any?]{
        var fieldValues = [Any]()
        
        for field in tasksFields  {
            fieldValues.append(objectTask.value(forKey: field)!)
        }
        
        return fieldValues
    }
    
    /// The mapToCKRecord function receives a Task object and transforms it into a CKRecord
    ///
    /// - Parameter objectTask: object to be transformed to CKRecord
    /// - Returns: the task in CKRecord form
    func mapToCKRecord(objectTask:Task, ckRecordTask:CKRecord) -> Void{
        let objectInfo = objectInfoInArray(objectTask)
        
        for i in 0...(tasksFields.count - 1) {
            ckRecordTask.setObject(objectInfo[i] as? CKRecordValue, forKey: self.tasksFields[i])
        }
        

        if let currentSession = objectTask.currentSession{
            
            if let recordID = currentSession.recordID {
                
                //Creating the currentSession in reference
                // FIXME: quickly press play/pause crashes because recordID isn't created in time.
                ckRecordTask["currentSession"] = CKReference(recordID: recordID, action: CKReferenceAction.none)
            } else {
                print("Error obtaining recordID from currentRecord in mapToCKRecord method.")
                ckRecordTask["currentSession"] = nil
            }
        } else {
            ckRecordTask["currentSession"] = nil
        }
        
        ckRecordTask["isRunning"] = (objectTask.isRunning ? 1 : 0) as CKRecordValue
        //ckRecordTask.setObject(objectTask.isRunning ? 1 : 0 as! CKRecordValue, forKey: "isRunning")
        
        //Creating the timeCountList
        var timeCountList = [CKReference]()
        
        for session in objectTask.sessions {
            if let recordID = session.recordID {
                timeCountList.append(CKReference(recordID: recordID, action: CKReferenceAction.none))
            } else {
                print("Couldn't find session recordID when mapping task to CKRecord.")
            }
        }
        
        // TODO: remove duplicates using sets (better performance).
        // Gets sessions from CloudKit, without dupicates.
        if var sessionRecords = (ckRecordTask["sessions"] as? [CKReference]) {
            sessionRecords.append(contentsOf: timeCountList.filter{
                if sessionRecords.contains($0) {
                    return false
                } else {
                    return true
                }
            })
            
            timeCountList = sessionRecords
        }
        
        var set = Set<CKReference>()
        let result = timeCountList.filter {
            guard !set.contains($0) else {
                return false
            }
            set.insert($0)
            return true
        }
        
        ckRecordTask["sessions"] = result as CKRecordValue
    }
    
    func getCurrentSession(currSessionID:CKRecordID, completionHandler: @escaping (TaskSession?) -> Swift.Void ){
        publicData.fetch(withRecordID: currSessionID) { (record, error) in
            if error == nil, let record = record{
                if let taskSession =  self.mapToTaskSession(record){
                    completionHandler(taskSession)
                } else {
                    completionHandler(nil)
                }
            } else {
                print("Error in getCurrentSession: \(String(describing: error))")
            }
        }
    }
    
    func containsSession(sessions: [TaskSession], session: TaskSession) -> Bool {
        for s in sessions {
            if s.recordID == session.recordID {
                return true
            }
        }
        
        return false
    }
    
    /// The mapToObject function returns a Task object given a CKRecord
    ///
    /// - Parameter record: our desired task in CKRecord type
    /// - Returns: our desired task in Task type
    func mapToObject (_ record:CKRecord) -> Task{
        
        let name = record.value(forKey: "name") as! String
        let isSubtask = record.value(forKey: "isSubtask") as! Int
//        let totalTime = record.value(forKey: "totalTime") as! Int
        let isActive = record.value(forKey: "isActive") as! Int
        let id = record.value(forKey:"id") as! String
        let timeCountList = record.value(forKey: "sessions") as? [CKReference] ?? [CKReference]()
        let finishedSessionTime = record.value(forKey: "totalTime") as! Int
        let isRunning = record.value(forKey: "isRunning") as? Int ?? 0 // FIXME: check for nil the right way.
        let currentSession = record.value(forKey: "currentSession") as? CKReference
    
        // TODO: guards for errors and nils
        
        let task = Task(name: name, isSubtask: isSubtask, isActive: isActive, id:id, finishedSessionTime: finishedSessionTime)
        
        task.recordName = record.recordID.recordName
        task.isRunning = (isRunning == 1 || currentSession != nil)
        
        if currentSession != nil {
//            print("currentSession on CloudKit!")
            self.getCurrentSession(currSessionID: currentSession!.recordID, completionHandler: { (currSession) in
                if let currSession = currSession {
                    task.currentSession = currSession
                } else {
                    print("Error mapping currentSession from CloudKit to object")
                    task.currentSession = nil
                }
            })
        }
        
        self.mapToTaskSessionList(referenceList: timeCountList) { (taskSessionList) in

            task.sessions = taskSessionList.filter {
                if self.containsSession(sessions: task.sessions, session: $0) {
                    return false
                } else {
                    return true
                }
            }

        }
        
        return task
    }
    
    /// The mapToObject function receives a CKRecord array and transforms it into a Task object
    ///
    /// - Parameter results: comes from the CloudKit requisition
    /// - Returns: a Task object
    func mapToObjectArray (_ results:[CKRecord]) -> [Task]{
        var tasksToDisplay = [Task]()
        
        tasksToDisplay = results.map { (record) -> Task in
            return mapToObject(record)
        }
        
        return tasksToDisplay

    }
    
    /// The getTasks function gets and returns all the active tasks in the CloudKit database
    ///
    /// - Parameter completionHandler:
    func getTasks(active: Bool = true, _ completionHandler: @escaping ([Task]) -> Swift.Void){
        var tasksToDisplay = [Task]()
        
        let predicateString = "isActive >= " + String(describing:(active ? 1 : 0))
        let predicate = NSPredicate(format: predicateString)
        
        let query = CKQuery(recordType: "Task", predicate:predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error " + error.debugDescription)
            } else {
                tasksToDisplay = self.mapToObjectArray(results!)
            }

            OperationQueue.main.addOperation ({ () -> Void in
                completionHandler(tasksToDisplay)
            })
            
        }
    }
    
    /// The getSpecificTask returns a Task object given it's id
        /// - Parameter id: id of the desired tasks
    func getSpecificTask(_ id:String, completion: @escaping (Task?,Error?) -> Void){
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                completion(nil, error)
                print("Error" + error.debugDescription)
            } else {
                if(results?.count == 1) {
                    let record = (results?[0])! as CKRecord
                    completion(self.mapToObject(record), nil)
                }
            }
        }
    }
    
    /// The delete function deletes a task in CloudKit
    ///
    /// - Parameter id: id of the task to be deleted
    func delete(_ id: String, completion: @escaping () -> Void){
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                if(results?.count == 1) {
                    let records = (results?[0])! as CKRecord
                    
                    self.publicData.delete(withRecordID: records.recordID, completionHandler: { (results, error) in
                        if error != nil {
                            print("Error" + error.debugDescription)
                        } else {
                            completion()
                        }
                    })
                }
            }
        }
    }
    
    /// The updateTask function updates a task in CloudKit
    ///
    /// - Parameters:
    ///   - task: task to be updated
    ///   - completion: do things when the function ends
    fileprivate func updateTask(task:Task, completion:@escaping (CKRecord?,Error?) -> Void){
        publicData.fetch(withRecordID: CKRecordID(recordName: task.recordName!)) { (record, error) in
            if (error == nil) {
                if let databaseRecord = record {
                    //Update record based on task information
                    self.mapToCKRecord(objectTask: task, ckRecordTask: databaseRecord)
                    
                    self.publicData.save(databaseRecord, completionHandler: { (finalRecord, error) in
                        if let savedRecord = finalRecord, error == nil {
                            completion(savedRecord,nil)
                        } else {
                            completion(nil, error)
                        }
                    })
                }
            } else {
                completion(nil,error)
            }
        }
    }
    
    /// The saveTask function updates if a task already exists or creates a new one into cloudkit
    ///
    /// - Parameters:
    ///   - task: the task Object to be updated or created into cloudkit
    ///   - completion: things to be done when the func ends
    func saveTask(task:Task, completion:@escaping (Task?,Error?) -> Void) {
        if task.recordName != nil {
            //Means the task already exists and we want to update her
            updateTask(task: task, completion: { (finalRecord, error) in
                if error == nil {
                    completion(self.mapToObject(finalRecord!),nil)
                } else {
                    completion(nil, error)
                }
            })
        } else {
            //Creating a record
            let ckRecordTask:CKRecord = CKRecord(recordType: "Task")
            mapToCKRecord(objectTask: task, ckRecordTask: ckRecordTask)
            
            //Uploading to CloudKit
            publicData.save(ckRecordTask, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
                if let savedRecord = record, error == nil {
                    completion(self.mapToObject(savedRecord),nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    
    /// The addTimeCount sends the timeCount to CloudKit and returns the recordName of the object added
    ///
    /// - Parameters:
    ///   - task: the owner of the session that will be added to cloudkit
    ///   - completionHandler: atributtes the recordName to the session added
    func addTimeCount(session:TaskSession, completionHandler: @escaping (CKRecordID) -> Swift.Void){
        let newTimeCount = CKRecord(recordType: "Session")
        
        newTimeCount.setObject(session.startDate as CKRecordValue, forKey: "startDate")
        newTimeCount.setObject(session.stopDate as CKRecordValue?, forKey: "stopDate")
        newTimeCount.setObject(session.durationInSeconds as CKRecordValue, forKey: "duration")
        
        publicData.save(newTimeCount, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Error addTimeCount --->" + (error!.localizedDescription))
            } else {
                completionHandler((record?.recordID)!)
            }
        })
    }
    
    func updateSession(session: TaskSession) {
        
        guard let recordID = session.recordID, let stopDate = session.stopDate else {
            print("Session is missing a CKRecord ID or stopDate to be updated.")
            return
        }
        
        publicData.fetch(withRecordID: recordID) { (record, error) in
            
            guard error == nil, let record = record else {
                print("Error when fetching session from CK")
                return
            }
            
            record["stopDate"] = stopDate as CKRecordValue
            
            self.publicData.save(record) {
                (savedRecord, error) in
                
                if error != nil {
                    print("Error when updating session record. Error when saving the record to CK.")
                } else {
                    print("Session updated on CloudKit.")
                }
                
            }
        }
        
        
    }
    
    // FIXME: discover why some attributes are missing during execution.
    
    /// The mapToTaskSession maps a TimeCount record into a TaskSession object
    ///
    /// - Parameter record: the TimeCount record to be mapped
    /// - Returns: a taskSession
    func mapToTaskSession (_ record:CKRecord) -> TaskSession? {

        
        
        guard let startDate = record.value(forKey: "startDate") as? Date,
            var duration  = record.value(forKey: "duration") as? Int else {
                print("Attributes missing when mapping task session CKRecord to object.")
                return nil
        }
        
        let stopDate = record.value(forKey: "stopDate") as? Date
        
        if stopDate != nil {
            duration = Int(DateInterval(start: startDate, end: stopDate!).duration)
        }
        
        
        return TaskSession(startDate: startDate, stopDate: stopDate, durationInSeconds: duration, recordID: record.recordID)
    }

    /// The mapToTaskSessionList transforms a reference list into a TaskSession list
    ///
    /// - Parameters:
    ///   - referenceList: the reference list to be transformed
    ///   - completionHandler: things to do only when the function ends
    func mapToTaskSessionList(referenceList: [CKReference], completionHandler: @escaping ([TaskSession]) -> Swift.Void){
        var recordIDList = [CKRecordID]()
        var taskSessionList = [TaskSession]()
        
        for reference in referenceList {
            recordIDList.append(reference.recordID)
        }
        
        let op = CKFetchRecordsOperation(recordIDs: recordIDList)
        op.database = publicData
        publicData.add(op)
        
        op.perRecordCompletionBlock = { (record, recordID, error) in
            if error == nil{
                if let result = record, let taskSession = self.mapToTaskSession(result){
                    taskSessionList.append(taskSession)

//                    else {
//                        print("Error when trying to map task session CKRecord to object.")
//                    }
                }
            }else{
                print("Error in mapping to recordIDList: \(String(describing: error))")
            }
            completionHandler(taskSessionList)
        }
    }
}
