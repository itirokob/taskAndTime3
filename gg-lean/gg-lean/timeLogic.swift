//
//  timeLogic.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/29/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation

class TimeLogic:NSObject{
    static let shared = TimeLogic()
    let manager = DataBaseManager.shared
    var activeTimers = [TimeCounter]()
    

    //Em timelogic, recebo a informação que o botão play foi pressionado e guardo a data que foi iniciado. A cada um segundo, eu faço dataAtual - dataInicio
    func playPressed(task:Task){
        task.isRunning = task.startSession(startDate: Date())
    }
    
    /// The pausePressed function sends the info from task's session to cloudkit
    ///
    /// - Parameter task: task to be paused
    func pausePressed(task:Task) {
        guard let finishedSession = task.stopSession() else {
            print("Error when trying to stop session.")
            return
        }
        
        task.isRunning = false
        
        print("Finished session \(finishedSession) in task \(task.name)")
        
        manager.addTimeCount(task: task, completionHandler: { (recordID) in
            
            if(task.sessions.count > 0) {
                task.sessions[task.getSessionsSize() - 1].recordID = recordID
                self.manager.saveTask(task: task, completion: { (task, error) in })
            }
        })
        
       
    }
}
