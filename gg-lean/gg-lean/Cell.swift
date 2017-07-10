//
//  Cell.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 7/2/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation
import UIKit
import SwipeCellKit

let activeCellColor     = UIColor(red: 247/255, green: 153/255, blue: 41/255, alpha: 1)
let unactiveCellColor = UIColor(white: 0.95, alpha: 1)

protocol CellProtocol: NSObjectProtocol
{
    func willStartTimer(cell: Cell)
    func willStopTimer(cell: Cell)
    func timerDidTick(cell: Cell)
    func willStartTimerBySiri(cell: Cell)
}

class Cell:SwipeTableViewCell{
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var playPauseSwitch: UISwitch!
    @IBOutlet weak var taskViewContainer: taskView!
    
    fileprivate var timer: Timer?
    weak var cellDelegate: CellProtocol?
    
    var timeLabelValue:Int = 0 {
        didSet{
            timeLabel.text = self.formattedTime(seconds: timeLabelValue)
        }
    }
    
    @IBAction func togglePlayPause(_ sender: UISwitch) {
        if sender.isOn {
            taskViewContainer.backgroundColor = activeCellColor
            startTimer()
        } else {
            taskViewContainer.backgroundColor = unactiveCellColor
                stopTimer()
        }
    }
    
    func initiateActivity( ){
        if playPauseSwitch.isOn == false{
            playPauseSwitch.isOn = true
        }
        taskViewContainer.backgroundColor = activeCellColor
        startTimer()
    }
    
    /// The updateTimers function is called everytime the Timer calls (every 1 second)
    func timerTick(){
        self.timeLabelValue += 1
        cellDelegate?.timerDidTick(cell: self)
    }
    
    
    /// The formattedTime returns the time into string given it's seconds
    fileprivate func formattedTime(seconds: Int) -> String{
        
        let minutes :Int = seconds / 60
        let seconds :Int = seconds - 60*minutes
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    //Starting timer
    fileprivate func startTimer(){
        if let cellDelegate = self.cellDelegate{
            cellDelegate.willStartTimer(cell: self)
        }
        timerInvalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(timerTick), userInfo: nil, repeats: true)
    }
    
    //Stoping timer
    fileprivate func stopTimer(){
        if let cellDelegate = self.cellDelegate{
            cellDelegate.willStopTimer(cell: self)
        }
        timerInvalidate()
    }
    
    //Invalidating Timer
    fileprivate func timerInvalidate(){
        if self.timer != nil {
            self.timer?.invalidate()
        }
    }
}
