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

class Cell:UITableViewCell{
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskViewContainer: taskView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    fileprivate var timer: Timer?
    var isOn : Bool  {
        get {
            return task.isRunning
        }
    }
    weak var cellDelegate: CellProtocol?
    var hasObserver: Bool = false
    let taskObserverPath: String = "sessions"
    var task: Task! {
        didSet {
            setViewProperties()
            print("task has been set to a cell")
            
            
            //            if task != nil {
            ////                print("added observer")
            //                self.task.addObserver(self, forKeyPath: taskObserverPath, options: [.new], context: nil)
            //                hasObserver = true
            //            }
        }
        willSet {
            if task != nil && hasObserver {
                self.task.removeObserver(self, forKeyPath: taskObserverPath)
                hasObserver = false
            }
        }
    }
    
    
    deinit {
        if task != nil && hasObserver {
            self.task.removeObserver(self, forKeyPath: taskObserverPath)
            hasObserver = false
        }
    }
    
    
    // MARK: - Key-Value Observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("observer notified!")
        if keyPath == taskObserverPath {
            // Update Time Label
            print("observer notified in keyPath!!")
            timeLabel.text = self.formattedTime(seconds: task.totalTime)
        } else if keyPath == "isOn" {
            print("isON!!")
        }
    }
    
    @IBAction func togglePlayPauseButton(_ sender: Any) {
        //        isOn = !isOn
        
        if isOn {
            stopTimer()
        } else {
            startTimer()
        }
        setViewProperties()
    }
    
    
    
    
    func setViewProperties() {
        taskLabel.text = task.name
        timeLabel.text = self.formattedTime(seconds: self.task.totalTime)
        timeLabel.textColor = task.isRunning ? UIColor.white : UIColor.black
        taskLabel.textColor = task.isRunning ? UIColor.white : UIColor.black
        taskViewContainer.backgroundColor = task.isRunning ? activeCellColor : unactiveCellColor
        playPauseButton.setImage(task.isRunning ? buttonPauseImage : buttonPlayImage, for: .normal)
    }
    
    
    /// The updateTimers function is called everytime the Timer calls (every 1 second)
    func timerTick(){
        timeLabel.text = self.formattedTime(seconds: self.task.totalTime)
        cellDelegate?.timerDidTick(cell: self)
    }
    
    
    /// The formattedTime returns the time into string given it's seconds
    fileprivate func formattedTime(seconds: Int) -> String{
        
        let minutes :Int = seconds / 60
        let seconds :Int = seconds - 60*minutes
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    //Starting timer
    func startTimer(){
        //        if let cellDelegate = self.cellDelegate{
        //            cellDelegate.willStartTimer(cell: self)
        //        }
        //        self.task.isRunning = self.task.startSession(startDate: Date())
        TimeLogic.shared.playPressed(task: self.task)
        setViewProperties()
        initializeTimer()
    }
    
    //Stoping timer
    func stopTimer(){
        if let cellDelegate = self.cellDelegate{
            cellDelegate.willStopTimer(cell: self)
        }
        setViewProperties()
        timerInvalidate()
    }
    
    func initializeTimer() {
        timerInvalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(timerTick), userInfo: nil, repeats: true)
    }
    
    //Invalidating Timer
    func timerInvalidate(){
        if let timer = self.timer {
            timer.invalidate()
        }
    }
}
