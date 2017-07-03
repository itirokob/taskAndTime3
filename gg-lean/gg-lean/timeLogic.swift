//
//  timeLogic.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/29/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation

class timeLogic:NSObject{
    static let shared = timeLogic()
    let manager = DataBaseManager.shared
    var activeTimers = [TimeCounter]()
    //E se o timer fosse na TaskViewController meramente ilustrativo e aqui só fosse o que vamos guardar no CloudKit?
    
    
    //Em timelogic, recebo a informação que o botão play foi pressionado e guardo a data que foi iniciado. A cada um segundo, eu faço dataAtual - dataInicio
    func playPressed(_ tasksID:String, cellsTotalTime:Int){
        let timer = TimeCounter(taskID: tasksID)
        timer.setStartDate(startDate: Date())
        timer.isActive = true
        
        activeTimers.append(timer)
    }
    
    func pausePressed(_ tasksID:String){
        for i in 0...activeTimers.count{
            if(activeTimers[i].taskID == tasksID){
                activeTimers[i].setEndDate(endDate: Date())
            }
        }
    }
}
