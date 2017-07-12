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

//Cell properties
let activeCellColor     = UIColor(red: 247/255, green: 153/255, blue: 41/255, alpha: 1)
let unactiveCellColor = UIColor(white: 0.95, alpha: 1)
let buttonPlayImage : UIImage = UIImage(named: "play")!
let buttonPauseImage : UIImage = UIImage(named: "pause")!

protocol CellProtocol: NSObjectProtocol
{
    func willStartTimer(cell: Cell)
    func willStopTimer(cell: Cell)
    func timerDidTick(cell: Cell)
    func willStartTimerBySiri(cell: Cell)
    func willStopTimerBySiri(cell: Cell)
}

class Cell:SwipeTableViewCell{
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskViewContainer: taskView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    fileprivate var timer: Timer?
    var isOn : Bool = false
    weak var cellDelegate: CellProtocol?
    
    var timeLabelValue:Int = 0 {
        didSet{
            timeLabel.text = self.formattedTime(seconds: timeLabelValue)
        }
    }
    
    @IBAction func togglePlayPauseButton(_ sender: Any) {
        isOn = !isOn
        if isOn {
            taskViewContainer.backgroundColor = activeCellColor
            self.taskLabel.textColor = UIColor.white
            self.timeLabel.textColor = UIColor.white
            self.playPauseButton.setImage(buttonPauseImage, for: .normal)
            startTimer()
        } else {
            taskViewContainer.backgroundColor = unactiveCellColor
            self.taskLabel.textColor = UIColor.black
            self.timeLabel.textColor = UIColor.black
            self.playPauseButton.setImage(buttonPlayImage, for: .normal)
            stopTimer()
        }
    }
    
    func initiateActivity( ){
        if isOn == false{
            isOn = true
        }
        self.playPauseButton.setImage(buttonPauseImage, for: .normal)
        self.taskLabel.textColor = UIColor.white
        self.timeLabel.textColor = UIColor.white
        taskViewContainer.backgroundColor = activeCellColor
        startTimer()
    }
    
    func stopActivity( ){
        if isOn == true{
            isOn = false
        }
        self.playPauseButton.setImage(buttonPlayImage, for: .normal)
        self.taskLabel.textColor = UIColor.black
        self.timeLabel.textColor = UIColor.black
        taskViewContainer.backgroundColor = unactiveCellColor
        stopTimer()
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
