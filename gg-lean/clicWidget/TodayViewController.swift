//
//  TodayViewController.swift
//  clicWidget
//
//  Created by Gustavo Avena on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource{
    let manager = DataBaseManager.shared
    var tasks = [Task]()
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.loadTasks()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    func loadTasks(){
        manager.getTasks { (tasks) in
            self.tasks = tasks
        }
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width,
                                                 height: 250): maxSize
        self.loadTasks()
        
        self.tableView.reloadData()
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        manager.getTasks { (tasks) in
            self.tasks = tasks
            print("tasks no widget:", self.tasks)
            self.tableView.reloadData()
            completionHandler(NCUpdateResult.newData)
        }
    }
    
    /// The formattedTime returns the time into string given it's seconds
    fileprivate func formattedTime(seconds: Int) -> String{
        
        let hours: Int = seconds/3600
        
        let minutes :Int = (seconds % 3600) / 60
        let seconds :Int = seconds - (3600 * hours) - (60 * minutes)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! Cell
        
        if cell.isOn == false{
            cell.startTimer()
            //willStartTimerBySiri(cell: cell)
        }
        else{
            cell.stopTimer()
            //willStopTimerBySiri(cell: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Cell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath) as! Cell
        let task = self.tasks[indexPath.row]
        
        cell.task = task
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myCell = cell as! Cell
        
        myCell.timerInvalidate()
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myCell = cell as! Cell
        
        myCell.timeLabel.text = myCell.task.getTimeString()
        
        if(myCell.task.isRunning) {
            myCell.initializeTimer()
        }
        
    }

}

