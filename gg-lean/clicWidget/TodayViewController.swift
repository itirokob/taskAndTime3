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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        manager.getTasks { (tasks) in
            Cache.shared().tasks = tasks
            print("tasks no widget:", Cache.shared().tasks)
            completionHandler(NCUpdateResult.newData)
        }
        
        
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let expanded = activeDisplayMode == .expanded
        preferredContentSize = expanded ? CGSize(width: maxSize.width,
                                                 height: CGFloat(tableView.numberOfRows(inSection: 1))*tableView.rowHeight + 200.0): maxSize
    }
    
}

extension TodayViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "widgetCell", for: indexPath)
        
        cell.detailTextLabel?.text = "00:00"
        cell.textLabel?.text = "Teste de Label"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }


}
