//
//  timeLogic.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/29/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation

class TimeLogic: NSObject {
    public static let shared = TimeLogic()
    let manager = DataBaseManager.shared
    

    //Em timelogic, recebo a informação que o botão play foi pressionado e guardo a data que foi iniciado. A cada um segundo, eu faço dataAtual - dataInicio
    func playPressed(task:Task, completionHandler: @escaping () -> Void){
        let sessionStarted = task.startSession(startDate: Date())
        
        if task.currentSession != nil {
            task.isRunning = true
            
            if sessionStarted {
                manager.addTimeCount(session: task.currentSession!) { (recordID) in
                    task.currentSession!.recordID = recordID
                    
                    self.manager.saveTask(task: task, completion: { (task, error) in
                        if error != nil{
                            print("Error in playPressed: \(String(describing: error))")
                        }
                        completionHandler()
                    })
                }

            }
            
        } else {
            print("task \(task.name) already has a running session.")
            completionHandler()
        }
    }
    
    /// The pausePressed function sends the info from task's session to cloudkit
    ///
    /// - Parameter task: task to be paused
    func pausePressed(task:Task) {
        guard let finishedSession = task.stopSession() else {
            print("Error when trying to stop session.")
            return
        }
        
        print("Finished session started at \(finishedSession.startDate) from task \(task.name)")
        
        manager.updateSession(session: finishedSession) // Update session record in CK.
        
        // Update Task record in CK.
        manager.saveTask(task: task, completion: { (task, error) in
            if error != nil{
                print("Error when updating task session record in pausePressed: \(String(describing: error))")
            } else {
                print("Task updated on Cloudkit.")
            }
        })
        
       
    }
}
