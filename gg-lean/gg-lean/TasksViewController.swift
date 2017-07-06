//
//  TasksViewController.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let manager = DataBaseManager.shared

    let timeLogic = TimeLogic.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addTaskField: UITextField!
    
    var tasksArray = [Task]()

    var refresh: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        
        //Adding the done button instead of "return" button on the keyboard
        addTaskField.returnKeyType = .done
        
        //Tap to dismiss the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TasksViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.dismissKeyboard()
    
        //Pull to refresh
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(TasksViewController.loadTasks), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresh)
        
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimers), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTasks()
    }
    
    func updateTimers(){
        if(tasksArray.count > 0){
            for i in 0...(tasksArray.count - 1){
                if tasksArray[i].isRunning == true {
                    tasksArray[i].updateSessionDuration()
                }
            }
            tableView.reloadData()
        }
    }
    
    func playPauseButton(_ sender: UIButton) {
        
        if tasksArray[sender.tag].isRunning == false {
            timeLogic.playPressed(task: tasksArray[sender.tag])
            print("Play \(tasksArray[sender.tag].name)")
            //mudar a imagem para o pause
        } else {
            timeLogic.pausePressed(task: tasksArray[sender.tag])
            print("Pause \(tasksArray[sender.tag].name)")
            //mudar a imagem para o play
        }
    }
    
    //Loads all the active tasks from the dataBase
    func loadTasks(){
        manager.getTasks { (tasks) in
            self.tasksArray = tasks
            self.tableView.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    //Action from the done button (which replaces the "return" button from the keyboard)
    @IBAction func doneAction(_ sender: Any) {
        if addTaskField.text == "" || (addTaskField.text?.isEmpty)!{
            self.dismissKeyboard()
        } else {
            //We want tasksDates and tasksTimes empty arrays because it will only receive values when the pause button is reached
            let dates = [Date]()
            let times = [Int]()
            let uuid = UUID().uuidString
            
            let task = Task(name: addTaskField.text!, isSubtask: -1, tasksDates: dates, tasksTimes: times, totalTime: 0, isActive: 1, id: uuid)
            
            manager.saveTask(task: task, completion: { (task2, error) in
                self.dismissKeyboard()
                self.addTaskField.text = ""
            })
            
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        cell.timeLabel.text = String(tasksArray[indexPath.row].getTotalTime())
        
        cell.taskLabel.text = tasksArray[indexPath.row].name
                
        cell.tag = indexPath.row
        
        cell.playPauseButton.tag = indexPath.row
        cell.playPauseButton.addTarget(self, action: #selector(TasksViewController.playPauseButton), for: .touchUpInside);

        return cell
    }
    //Swipe to delete a task
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            manager.delete(tasksArray[indexPath.row].id)
            tasksArray.remove(at: indexPath.row)
            self.tableView.isEditing=false;
        }
    }
}
