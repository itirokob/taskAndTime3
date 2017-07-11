//
//  StatisticsViewController.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    let manager = DataBaseManager.shared
    var tasksArray = [Task]()
    var sendingTask: Task?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func loadTasks(){
        manager.getTasks { (tasks) in
            self.tasksArray = tasks
            
            OperationQueue.main.addOperation({
                self.tableView.reloadData()
                //self.refresh.endRefreshing()
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTasks()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationController = segue.destination as? ActivityDescriptionViewController
        destinationController?.describedTask = sendingTask!
    }

}

extension StatisticsViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
        let task = tasksArray[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.getTimeString()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sendingTask = tasksArray[indexPath.row]
        performSegue(withIdentifier: "showDescription", sender: self)
        
    }

}
