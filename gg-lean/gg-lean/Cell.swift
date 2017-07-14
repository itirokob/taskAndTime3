//
//  Cell.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 7/2/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation
import UIKit

//Cell properties
let activeCellColor     = UIColor(red: 247/255, green: 153/255, blue: 41/255, alpha: 1)
let unactiveCellColor = UIColor(white: 0.95, alpha: 1)
let buttonPlayImage : UIImage = UIImage(named: "play")!
let buttonPauseImage : UIImage = UIImage(named: "pause")!

protocol CellProtocol: NSObjectProtocol
{
    //func willStartTimer(cell: Cell)
    //func willStopTimer(cell: Cell)
    //func timerDidTick(cell: Cell)
    //func willStartTimerBySiri(cell: Cell)
    //func willStopTimerBySiri(cell: Cell)
}

class Cell:UITableViewCell{
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var taskViewContainer: taskView?
    @IBOutlet weak var playPauseButton: UIButton!
    
    fileprivate var timer: Timer?
    var isOn : Bool  {
        get {
            return task.isRunning
        }
    }
    
    var timeLogic = TimeLogic.shared
    var hasObserver: Bool = false
    let taskObserverPath: String = "sessions"
    var task: Task! {
        didSet {
            setViewProperties()
        }
    }
    
    @IBAction func togglePlayPauseButton(_ sender: Any) {
        if isOn {
            stopTimer()
        } else {
            startTimer()
        }
        setViewProperties()
    }
    
    func setViewProperties() {
        taskLabel.text = task.name
        timeLabel.text = self.task.getTimeString()
        timeLabel.textColor = task.isRunning ? UIColor.white : UIColor.black
        taskLabel.textColor = task.isRunning ? UIColor.white : UIColor.black
        playPauseButton.setImage(task.isRunning ? buttonPauseImage : buttonPlayImage, for: .normal)
        
        if taskViewContainer != nil{
            taskViewContainer?.backgroundColor = task.isRunning ? activeCellColor : unactiveCellColor
        }
    }
    
    
    /// The updateTimers function is called everytime the Timer calls (every 1 second)
    func timerTick(){
        timeLabel.text = self.task.getTimeString()
    }
    
    
    /// The formattedTime returns the time into string given it's seconds
    fileprivate func formattedTime(seconds: Int) -> String{
        
        let hours: Int = seconds/3600
        
        let minutes :Int = (seconds % 3600) / 60
        let seconds :Int = seconds - (3600 * hours) - (60 * minutes)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    //Starting timer
    func startTimer(){
        self.isUserInteractionEnabled = false
        
        // TODO: activity indicator in button is causing bugs. Going to implement it later...
        TimeLogic.shared.playPressed(task: self.task, completionHandler: {
            self.isUserInteractionEnabled = true
        })
        setViewProperties()
        initializeTimer()
    }
    
    //Stoping timer
    func stopTimer(){
        TimeLogic.shared.pausePressed(task: self.task)
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


// MARK - loading button.
class LoadingButton: UIButton {
    
    struct ButtonState {
        var state: UIControlState
        var title: String?
        var image: UIImage?
    }
    
    private (set) var buttonStates: [ButtonState] = []
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = self.titleColor(for: .normal)
        self.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraints([xCenterConstraint, yCenterConstraint])
        return activityIndicator
    }()
    
    func showLoading() {
        activityIndicator.startAnimating()
        var buttonStates: [ButtonState] = []
        for state in [UIControlState.disabled] {
            let buttonState = ButtonState(state: state, title: title(for: state), image: image(for: state))
            buttonStates.append(buttonState)
            setTitle("", for: state)
            setImage(UIImage(), for: state)
        }
        self.buttonStates = buttonStates
        isEnabled = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        for buttonState in buttonStates {
            setTitle(buttonState.title, for: buttonState.state)
            setImage(buttonState.image, for: buttonState.state)
        }
        isEnabled = true
    }
    
}
