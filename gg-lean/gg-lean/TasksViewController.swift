//
//  TasksViewController.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import Intents

let backgroundBlue : UIColor = UIColor(red: 34/255, green: 128/255, blue:171/255, alpha: 1)

class TasksViewController: UIViewController{
    let manager = DataBaseManager.shared

    let timeLogic = TimeLogic.shared
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskField: UITextField!

    var tasksNameArray: [String] = []
    public static var startedActivityOnInit:String?

    var refresh: UIRefreshControl!
    
    var initialIndexPath: IndexPath?
    var cellSnapshot: UIView?
    func updateTasksNameArray(){
        var tasksNames = [String]()
        
        for task in Cache.shared().tasks {
            tasksNames.append(task.name)
        }
        tasksNameArray = tasksNames
        
        updateSiriVocabulary()
    }
    
    func updateSiriVocabulary(){
        //Iniciando vocabulário da Siri através de um vetor de Strings - tasksNameArray
        INVocabulary.shared().setVocabularyStrings(NSOrderedSet(array: tasksNameArray), of: .workoutActivityName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let populator = PopulateTasks()
//        populator.populateTasks()
//        populator.deleteAllRecords()

        
        tableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        addLongPressGesture()
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = backgroundBlue
        
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

        //Siri
        INPreferences.requestSiriAuthorization { (status) in
            
        }
        self.loadTasks()
        updateTasksNameArray( )
        
//        populator.deleteAllRecords()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Loads all the active tasks from the dataBase
    func loadTasks(){
        
        Cache.shared().updateTasks(active: true){ (tasks) in
            OperationQueue.main.addOperation({
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                self.updateTasksNameArray()
            })
        }

        
    }
    
    //Action from the done button (which replaces the "return" button from the keyboard)
    @IBAction func doneAction(_ sender: Any) {
        if addTaskField.text == "" || (addTaskField.text?.isEmpty)!{
            self.dismissKeyboard()
        } else {
            //We want tasksDates and tasksTimes empty arrays because it will only receive values when the pause button is reached
            
            // TODO: default value for unique ID should be in the constructor.
            let task = Task(name: addTaskField.text!, isSubtask: -1, isActive: 1, id: UUID().uuidString, finishedSessionTime: 0)
            
            manager.saveTask(task: task, completion: { (task2, error) in
                
                guard error == nil, let task = task2 else {
                    print("Error in adding task: \(String(describing: error))")
                    return
                }
                
                OperationQueue.main.addOperation({
                    Cache.shared().tasks.insert(task, at: 0)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
                    self.tableView.endUpdates()
                })
                
               
            })
            self.dismissKeyboard()
            self.addTaskField.text = ""
            
            updateTasksNameArray()
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}



extension TasksViewController {

    
    func addLongPressGesture() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        tableView.addGestureRecognizer(longpress)
    }
    
    func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        let locationInView = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began {
            if indexPath != nil {
                initialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!)
                cellSnapshot = snapshotOfCell(inputView: cell!)
                var center = cell?.center
                cellSnapshot?.center = center!
                cellSnapshot?.alpha = 0.0
                tableView.addSubview(cellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    self.cellSnapshot?.center = center!
                    self.cellSnapshot?.transform = (self.cellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.cellSnapshot?.alpha = 0.99
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        } else if sender.state == .changed {
            var center = cellSnapshot?.center
            center?.y = locationInView.y
            cellSnapshot?.center = center!
            
            if ((indexPath != nil) && (indexPath != initialIndexPath)) {
                swap(&Cache.shared().tasks[indexPath!.row], &Cache.shared().tasks[initialIndexPath!.row])
                tableView.moveRow(at: initialIndexPath!, to: indexPath!)
                initialIndexPath = indexPath
            }
        } else if sender.state == .ended {
            let cell = tableView.cellForRow(at: initialIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.cellSnapshot?.center = (cell?.center)!
                self.cellSnapshot?.transform = CGAffineTransform.identity
                self.cellSnapshot?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    self.initialIndexPath = nil
                    self.cellSnapshot?.removeFromSuperview()
                    self.cellSnapshot = nil
                }
            })
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}


// MARK: Table View Extensions
extension TasksViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cache.shared().tasks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        let task = Cache.shared().tasks[indexPath.row]
    
        cell.task = task
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear

        
        
        //Verifica se a task dessa célula foi inicilizada por um comando da Siri
        if let acName = TasksViewController.startedActivityOnInit{
            if cell.taskLabel.text == acName{
                TasksViewController.startedActivityOnInit = nil
                cell.startTimer()
            }
        }
        
        return cell
    }
    
    //Essa função está aqui por enquanto.... ela ativa um timer, mas deveria collapsar uma célula no futuro
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! Cell
        
        if cell.isOn == false{
            cell.startTimer()
        }
        else{
            cell.stopTimer()
        }
    }
    
    //Swipe to delete a task
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "               ") { action, indexPath in
            self.manager.delete(Cache.shared().tasks[indexPath.row].id, completion: {
                OperationQueue.main.addOperation({
                    Cache.shared().tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.isEditing=false
                })
            })
        }
        delete.backgroundColor = UIColor.init(red: 38, green: 147, blue: 186, alpha: 0)
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "trashCan")!)
        
        let archive = UITableViewRowAction(style: .default, title: "            ") { (action, indexPath) in
            Cache.shared().tasks[indexPath.row].isActive = 0
            self.manager.saveTask(task: Cache.shared().tasks[indexPath.row], completion: { (task, error) in
                OperationQueue.main.addOperation({
                    Cache.shared().tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.isEditing=false
                    self.tableView.isEditing = false
                })
            })
        }
        archive.backgroundColor = UIColor(patternImage: UIImage(named: "archive")!)

        return [delete, archive]
    }
}
















