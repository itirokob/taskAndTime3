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
    let manager = DataBaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
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
        
        manager.getTasks { (tasks) in
            Cache.shared().tasks = tasks
            print("tasks no widget:", Cache.shared().tasks)
            completionHandler(NCUpdateResult.newData)
        }
        
        
    }
    
}
