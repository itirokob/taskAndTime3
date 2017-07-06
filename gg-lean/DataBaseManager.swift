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
    let tasksFields = ["name", "isSubtask", "tasksDates", "tasksTimes", "totalTime", "isActive", "id"]
    
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
    
    
    /// The delete function deletes a task in CloudKit
    ///
    /// - Parameter id: id of the task to be deleted
    func delete(_ id: String){
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
                            print("Record deleted!!! :D")
                        }
                    })
                }
            }
        }
    }
    
    /// The mapToObject function returns a Task object given a CKRecord
    ///
    /// - Parameter record: our desired task in CKRecord type
    /// - Returns: our desired task in Task type
    func mapToObject (_ record:CKRecord) -> Task{
        let name = record.value(forKey: "name") as! String
        let isSubtask = record.value(forKey: "isSubtask") as! Int
        let totalTime = record.value(forKey: "totalTime") as! Int
        let tasksDates = record.value(forKey: "tasksDates") as! [Date]
        let tasksTimes = record.value(forKey: "tasksTimes") as! [Int]
        let isActive = record.value(forKey: "isActive") as! Int
        let id = record.value(forKey:"id") as! String
    
        let task = Task(name: name, isSubtask: isSubtask, tasksDates: tasksDates, tasksTimes: tasksTimes, totalTime: totalTime, isActive: isActive, id:id)
        task.recordName = record.recordID.recordName
        
        return task
    }
    
    
    /// The getSpecificTask returns a Task object given it's id
    ///
    /// - Parameter id: id of the desired tasks
    @discardableResult func getSpecificTask(_ id:String, completion: @escaping (Task?,Error?) -> Void){
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
    
    /// The getSpecificCKRecordTask returns a CKRecord task object given it's id
    ///
    /// - Parameter id: id of the desired tasks
    @discardableResult func getSpecificCKRecordTask(_ id:String, completion: @escaping (CKRecord?,Error?) -> Void){
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let query = CKQuery(recordType: "task", predicate: predicate)
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                completion(nil, error)
                print("Error" + error.debugDescription)
            } else {
                if(results?.count == 1) {
                    let record = (results?[0])! as CKRecord
                    completion(record, nil)
                }
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
            //retrieve task
            publicData.fetch(withRecordID: CKRecordID(recordName:task.recordName!)) { (record, error) in
                if (error == nil) {
                    if let databaseRecord = record {
                        //Update record based on task information
                        self.mapToCKRecord(objectTask: task, ckRecordTask: databaseRecord)
                        
                        //databaseRecord["totalTime"] = (task.getTotalTime()) as? CKRecordValue
                        self.publicData.save(databaseRecord, completionHandler: { (finalRecord, error) in
                            if let savedRecord = finalRecord, error == nil {
                                completion(self.mapToObject(savedRecord),nil)
                            } else {
                                completion(nil, error)
                            }
                        })
                    }
                } else {
                    completion(nil,error)
                }
            }
        } else {
            //create record
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
    
    
    /// The addTimeCount function adds a timeCount object into the timeCountList from cloudkit
    ///
    /// - Parameters:
    ///   - taskID: id of the task we'll add the new time Count
    ///   - startDate: start date of the task session to be uploaded
    ///   - duration: duration of the task session to be uploaded
    ///   - completionHandler: things to be done when the func ends
    func addTimeCount(task:Task, completionHandler: @escaping (CKRecord) -> Swift.Void){
        let newTimeCount = CKRecord(recordType: "timeCount")
        newTimeCount.setObject(task.sessions[task.getSessionsSize() - 1].startDate as CKRecordValue, forKey: "startDate")
        newTimeCount.setObject(task.sessions[task.getSessionsSize() - 1].durationInSeconds as CKRecordValue, forKey: "duration")
        
        publicData.fetch(withRecordID: CKRecordID(recordName:task.recordName!)) { (record, error) in
            if(error == nil){
                if let dbRecord = record {
                    var timeCountList = [CKReference]()
                    
                    if (dbRecord["timeCountList"] == nil) {
                        dbRecord["timeCountList"] = timeCountList as CKRecordValue
                    } else {
                        timeCountList = dbRecord["timeCountList"] as! [CKReference]
                    }
                    
                    timeCountList.append(CKReference(recordID: newTimeCount.recordID, action: CKReferenceAction.none))
                    
                    dbRecord["timeCountList"] = timeCountList as CKRecordValue
                }
            }else{
                ///completionHandler(nil)
            }
        }
        
        
        //Uploading to CloudKit
        publicData.save(newTimeCount, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Error --->" + (error!.localizedDescription))
            }
            
//            self.getSpecificTask(taskID, completion: { (taskInTaskForm, error) in
//                if error != nil{
//                    print("Error" + error.debugDescription)
//                } else {
//                    let task = CKRecord(recordType: "task")
//                    
//                    self.mapToCKRecord(objectTask: taskInTaskForm!, ckRecordTask: task)
//                    
//                    var timeCountList = [CKReference]()
//                    
//                    if (task["timeCountList"] == nil) {
//                        task["timeCountList"] = timeCountList as CKRecordValue
//                    } else {
//                        timeCountList = task["timeCountList"] as! [CKReference]
//                    }
//                    
//                    timeCountList.append(CKReference(recordID: record!.recordID, action: CKReferenceAction.none))
//                    
//                    task["timeCountList"] = timeCountList as CKRecordValue
//                    
//                    OperationQueue.main.addOperation ({ (Task) -> Void in
//                        self.updateTasksSessions(task:
//                            self.mapToObject(task))
//                        completionHandler(task)
//                    })
//                }
//            })
            
//            self.getSpecificCKRecordTask(task) { (task, error) in
//                if error != nil{
//                    print("Error" + error.debugDescription)
//                } else {
//                    var timeCountList = [CKReference]()
//                    
//                    if (task!["timeCountList"] == nil) {
//                        task!["timeCountList"] = timeCountList as CKRecordValue
//                    } else {
//                        timeCountList = task!["timeCountList"] as! [CKReference]
//                    }
//                    
//                    timeCountList.append(CKReference(recordID: record!.recordID, action: CKReferenceAction.none))
//                    
//                    task!["timeCountList"] = timeCountList as CKRecordValue
//                
////                    OperationQueue.main.addOperation ({ () -> Void in
////                        completionHandler()
////                    })
//                }
//            }
//            OperationQueue.main.addOperation ({ () -> Void in
//                //completionHandler()
//            })
        })
    }
    
    
    /// The updateTimeCountList function gets the timeCount objects from CloudKit and transforms it into the TaskSession struct into Task object
    ///
    /// - Parameter task: the task from which we want to get the data
    func updateTasksSessions(task:Task){
        var duration:Int = 0
        var startDate:Date = Date()
        
        getSpecificCKRecordTask(task.id) { (record, error) in
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                let times = record?.value(forKey: "timeCountList") as? [CKReference]
                
                if let list = times {
                    
                    let idList = list.map({ (reference) -> CKRecordID in
                        return reference.recordID
                    })
                    
                    let fetch = CKFetchRecordsOperation(recordIDs: idList)
                    
                    fetch.fetchRecordsCompletionBlock = {(records, error) in
                        if(records != nil){
                            var i = 0
                            for recordId in records!.keys {
                                duration = records![recordId]?.value(forKey: "duration") as! Int
                                startDate = records![recordId]?.value(forKey: "startDate") as! Date
                                task.sessions[i].durationInSeconds = duration
                                task.sessions[i].startDate = startDate
                                i+=1
                            }
//                            
//                            for i in 0...((records?.count)! -  1){
//                                task.sessions[i].durationInSeconds = duration
//                                task.sessions[i].startDate = startDate
//                            }
                        }
                    }
                    
                    fetch.database = self.publicData
                    fetch.start()
                }
            }
        }

    }
}
