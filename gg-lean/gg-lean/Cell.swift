//
//  Cell.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 7/2/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation
import UIKit


protocol CellProtocol: NSObjectProtocol
{
    func willStartTimer(cell: Cell)
    func willStopTimer(cell: Cell)
    func timerDidTick(cell: Cell)
}

class Cell:UITableViewCell{
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var playPauseSwitch: UISwitch!
    fileprivate var timer: Timer?
    weak var delegate: CellProtocol?
    
    var timeLabelValue:Int = 0 {
        didSet{
            timeLabel.text = self.formattedTime(seconds: timeLabelValue)
        }
    }
    
    @IBAction func togglePlayPause(_ sender: UISwitch) {
        if sender.isOn {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    /// The updateTimers function is called everytime the Timer calls (every 1 second)
    func timerTick(){
        self.timeLabelValue += 1
        delegate?.timerDidTick(cell: self)
    }
    
    
    /// The formattedTime returns the time into string given it's seconds
    fileprivate func formattedTime(seconds: Int) -> String{
        
        let minutes :Int = seconds / 60
        let seconds :Int = seconds - 60*minutes
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }
    
    //Starting timer
    fileprivate func startTimer(){
        if let delegate = self.delegate{
            delegate.willStartTimer(cell: self)
        }
        timerInvalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(timerTick), userInfo: nil, repeats: true)
    }
    
    //Stoping timer
    fileprivate func stopTimer(){
        if let delegate = self.delegate{
            delegate.willStopTimer(cell: self)
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
