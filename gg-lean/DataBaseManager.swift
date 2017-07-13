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
    let publicData = CKContainer.default().publicCloudDatabase
    
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
        
        var timeCountList = [CKReference]()
        
        if (ckRecordTask["timeCountList"] == nil) {
            ckRecordTask["timeCountList"] = timeCountList as CKRecordValue
            for session in objectTask.sessions {
                timeCountList.append(CKReference(recordID: session.recordID!, action: CKReferenceAction.none))
            }
        } else {
            timeCountList = ckRecordTask["timeCountList"] as! [CKReference]
            if objectTask.getSessionsSize() > 0 && objectTask.sessions[objectTask.getSessionsSize() - 1].recordID != nil{
                timeCountList.append(CKReference(recordID: objectTask.sessions[objectTask.getSessionsSize() - 1].recordID!, action: CKReferenceAction.none))
            }
        }

        ckRecordTask["timeCountList"] = timeCountList as CKRecordValue
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
        let timeCountList = record.value(forKey: "timeCountList") as! [CKReference]
        let finishedSessionTime = record.value(forKey: "totalTime") as! Int
    
        // TODO: guards for errors and nils
        
        let task = Task(name: name, isSubtask: isSubtask, isActive: isActive, id:id, finishedSessionTime: finishedSessionTime)
        
        task.recordName = record.recordID.recordName
        self.mapToTaskSessionList(referenceList: timeCountList) { (taskSessionList) in
            task.sessions = taskSessionList
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
    func getTasks(_ completionHandler: @escaping ([Task]) -> Swift.Void){
        var tasksToDisplay = [Task]()
        
        let predicate = NSPredicate(format: "isActive >= 1")
        
        let query = CKQuery(recordType: "task", predicate:predicate)
        
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error" + error.debugDescription)
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
        let query = CKQuery(recordType: "task", predicate: predicate)
        
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
        let query = CKQuery(recordType: "task", predicate: predicate)
        
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
    func updateTask(task:Task, completion:@escaping (CKRecord?,Error?) -> Void){
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
            let ckRecordTask:CKRecord = CKRecord(recordType: "task")
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
    func addTimeCount(task:Task, completionHandler: @escaping (CKRecordID) -> Swift.Void){
        let newTimeCount = CKRecord(recordType: "timeCount")
        newTimeCount.setObject(task.sessions[task.getSessionsSize() - 1].startDate as CKRecordValue, forKey: "startDate")
        newTimeCount.setObject(task.sessions[task.getSessionsSize() - 1].durationInSeconds as CKRecordValue, forKey: "duration")
        
        publicData.save(newTimeCount, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Error addTimeCount --->" + (error!.localizedDescription))
            } else {
                completionHandler((record?.recordID)!)
            }
        })
    }
    
    
    /// The mapToTaskSession maps a TimeCount record into a TaskSession object
    ///
    /// - Parameter record: the TimeCount record to be mapped
    /// - Returns: a taskSession
    func mapToTaskSession (_ record:CKRecord) -> TaskSession{
        let startDate = record.value(forKey: "startDate") as! Date
        let stopDate = record.value(forKey: "stopDate") as? Date
        let duration = record.value(forKey: "duration") as! Int
        let recordID = record.recordID
        
        return TaskSession(startDate: startDate, stopDate: stopDate, durationInSeconds: duration, recordID: recordID)
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
                if let result = record{
                    taskSessionList.append(self.mapToTaskSession(result))
                }
            }else{
                print("Error in mapping to recordIDList: \(String(describing: error))")
            }
            completionHandler(taskSessionList)
        }
    }
}
