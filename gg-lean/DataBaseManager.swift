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
    
    let tasksFields = ["name", "isSubtask", "tasksDates", "tasksTimes", "totalTime", "isActive", "id"]
    
    func objectInfoInArray (_ objectTask:Task)->[Any]{
        return [objectTask.name, objectTask.isSubtask, objectTask.tasksDates, objectTask.tasksTimes, objectTask.totalTime, objectTask.isActive, objectTask.id] as [Any]
    }
    
    /// The mapToCKRecord function receives a Task object and transforms it into a CKRecord
    ///
    /// - Parameter objectTask: object to be transformed to CKRecord
    /// - Returns: the task in CKRecord form
    func mapToCKRecord(_ objectTask:Task) -> CKRecord{
        let ckRecordTask = CKRecord(recordType: "task")
        
        let objectInfo = objectInfoInArray(objectTask)
        
        for i in 0...(tasksFields.count - 1) {
            ckRecordTask.setObject(objectInfo[i] as? CKRecordValue, forKey: self.tasksFields[i])
        }
        
        return ckRecordTask
    }
    
    /// The addNewTask func receives a Task object and with it sends all the informations to CloudKit
    ///
    /// - Parameters:
    ///   - task: object received from the view
    ///   - completionHandler: commands to be executed when the function ends
    func addNewTask(_ task:Task, completionHandler: @escaping () -> Swift.Void){
        let newTask = mapToCKRecord(task)
        
        //Uploading to CloudKit
        publicData.save(newTask, completionHandler: {(record:CKRecord?, error:Error?) -> Void in
            if error != nil{
                print("Error --->" + (error!.localizedDescription))
            }
            
            OperationQueue.main.addOperation ({ () -> Void in
                completionHandler()
            })
        })
    }
    
    /// The mapToObject function receives a CKRecord array and transforms it into a Task object
    ///
    /// - Parameter results: comes from the CloudKit requisition
    /// - Returns: a Task object
    func mapToObjectArray (_ results:[CKRecord]) -> [Task]{
        var tasksToDisplay = [Task]()
        
        for record in results {
            let name = record.value(forKey: "name") as! String
            let isSubtask = record.value(forKey: "isSubtask") as! Int
            let totalTime = record.value(forKey: "totalTime") as! Int
            let tasksDates = record.value(forKey: "tasksDates") as! [Date]
            let tasksTimes = record.value(forKey: "tasksTimes") as! [Int]
            let isActive = record.value(forKey: "isActive") as! Int
            let id = record.value(forKey:"id") as! String
            
            tasksToDisplay.append(
                Task(name: name, isSubtask: isSubtask, tasksDates: tasksDates, tasksTimes: tasksTimes, totalTime: totalTime, isActive: isActive, id:id)
            )
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
    
    /// The getTotalTime function returns que totalTime of a given task (identified by a id)
    ///
    /// - Parameter id: id of the task whom we want the total time from
    /// - Returns: the desired totalTime 
    func getTotalTime(_ id:String) -> Int{
        var soughtTotalTime = -1
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let query = CKQuery(recordType: "task", predicate: predicate)
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                if(results?.count == 1) {
                    let record = (results?[0])! as CKRecord
                    soughtTotalTime = record.value(forKey:"totalTime") as! Int
                }
            }
        }
        
        return soughtTotalTime
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
        
        return Task(name: name, isSubtask: isSubtask, tasksDates: tasksDates, tasksTimes: tasksTimes, totalTime: totalTime, isActive: isActive, id:id)
    }
    
    
    /// The getSpecificTask returns a Task object given it's id
    ///
    /// - Parameter id: id of the desired tasks
    func getSpecificTask(_ id:String) -> Task{
        var soughtTask:Task? = nil
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let query = CKQuery(recordType: "task", predicate: predicate)
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                if(results?.count == 1) {
                    let record = (results?[0])! as CKRecord
                    soughtTask = self.mapToObject(record)
                }
            }
        }
        
        return soughtTask!
    }
    
    func updateTotalTime(_ id:String, totalTime:Int){
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let query = CKQuery(recordType: "task", predicate: predicate)
        
        publicData.perform(query, inZoneWith: nil) { (results, error) in
            if error != nil{
                print("Error" + error.debugDescription)
            } else {
                if(results?.count == 1) {
                    let record = (results?[0])! as CKRecord
                    record.setObject(totalTime as CKRecordValue?, forKey: "totalTime")
                    
                    self.publicData.save(record, completionHandler: { (result, error) in
                        if error != nil{
                            print("error-->" + error.debugDescription)
                        } else {
                            print("TotalTime atualizado")
                        }
                    })
                } else {
                    print("Task não encontrada")
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}
