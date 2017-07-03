//
//  TasksViewController.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

enum buttonsState {
    case play
    case pause
}

class TasksViewController: UIViewController {
    let manager = DataBaseManager.shared

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addTaskField: UITextField!
    
    var playPauseState = buttonsState.play
    
    var tasksArray = [Task]()

    var refresh: UIRefreshControl!
    
    var selectedIndex:IndexPath?
    var isExpanded = false

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
        
        
       // let nib = UINib.init(nibName: "CustomTableViewCell", bundle: nil)
       // self.tableView.register(nib, forCellReuseIdentifier: "customCell")
        
       self.tableView.estimatedRowHeight = 40
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTasks()
    }
    
    func updateTimers(){
        if(tasksArray.count > 0){
            for i in 0...(tasksArray.count - 1){
                if tasksArray[i].playPauseState == buttonsState.pause{
                    tasksArray[i].totalTime += 1
                }
            }
            tableView.reloadData()
        }
    }
    
    func playPauseButton(_ sender: UIButton) {
        if tasksArray[sender.tag].playPauseState == buttonsState.play{
            tasksArray[sender.tag].playPauseState = buttonsState.pause
            print("Play \(tasksArray[sender.tag].name)")
            //mudar a imagem para o pause, aqui usamos o button
        } else {
            tasksArray[sender.tag].playPauseState = buttonsState.play
            print("Pause \(tasksArray[sender.tag].name)")
            //mudar a imagem para o play, aqui usamos o button
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
            print(uuid)
            
            let task = Task(name: addTaskField.text!, isSubtask: -1, tasksDates: dates, tasksTimes: times, totalTime: 0, isActive: 1, id: uuid)
            
            manager.addNewTask(task, completionHandler: { 
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
    
}


//MARK: Table View Extension
extension  TasksViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if isExpanded && self.selectedIndex == indexPath{
            return 200
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /*
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        
        cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        cell.timeLabel.text = tasksArray[indexPath.row].getTimeString()
        
        cell.taskLabel.text = tasksArray[indexPath.row].name
        
        cell.tag = indexPath.row
        
        cell.playPauseButton.tag = indexPath.row
        cell.playPauseButton.addTarget(self, action: #selector(TasksViewController.playPauseButton), for: .touchUpInside);
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
 */
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celola", for: indexPath) as! MyTableViewCell
        
        cell.label.text = indexPath.row % 2 == 0 ? "Blah!" : "Blah\nBlah\n"
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentCell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        //self.isExpanded = currentCell.collapse()
        
        self.selectedIndex = indexPath
        self.didExpandCell()
        
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.view.layoutIfNeeded()
    }
    
    func didExpandCell(){
        self.isExpanded = !self.isExpanded
        self.tableView.reloadRows(at: [selectedIndex!], with: .automatic)
    }
}
