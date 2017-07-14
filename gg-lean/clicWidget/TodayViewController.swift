//
//  TodayViewController.swift
//  clicWidget
//
//  Created by Gustavo Avena on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var tableView: UITableView!
    let manager = DataBaseManager.shared
    var showMore : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadTasks()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadTasks(){
        manager.getTasks { (tasks) in
            
            Cache.shared().tasks = tasks
        }
    }
    
    func updateTasks(completionHandler: (@escaping (Bool) -> Void)) {
        manager.getTasks { (tasks) in
            
            Cache.shared().tasks = tasks
            
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        Cache.shared().updateTasks(completionHandler: { (tasks) in
            print("tasks no widget:", Cache.shared().tasks)
            self.tableView.reloadData()
            completionHandler(NCUpdateResult.newData)
        })
        
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        
        self.showMore = expanded ? true : false
        preferredContentSize = expanded ? CGSize(width: maxSize.width,
                                                 height: 250): maxSize
        tableView.reloadData()
    }
    
}

extension TodayViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.showMore == true{
            return 3
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath)
        print("Widget trying to create and load cell")
        print( Cache.shared().tasks,  Cache.shared().tasks.count)
        
        let task = Cache.shared().tasks[indexPath.row]
        print("Widget: \(task.name)")
        //cell.detailTextLabel?.text = task.getTimeString()
        //cell.textLabel?.text = task.name
        
        cell.detailTextLabel?.text = "ksdhfb"
        cell.textLabel?.text = "???r"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }


}
