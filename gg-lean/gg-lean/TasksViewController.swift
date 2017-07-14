//
//  TasksViewController.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import Intents
import SwipeCellKit

let backgroundBlue : UIColor = UIColor(red: 34/255, green: 128/255, blue:171/255, alpha: 1)

class TasksViewController: UIViewController{
    let manager = DataBaseManager.shared

    let timeLogic = TimeLogic.shared
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTaskField: UITextField!
    
//    var Cache.shared().tasks  = {
//        return Cache.shared().tasks
//    }()
    
    var tasksNameArray: [String] = []
    public static var startedActivityOnInit:String?

    var refresh: UIRefreshControl!
    
    func updateTasksNameArray(){
        
        for task in Cache.shared().tasks {
            tasksNameArray.append(task.name)
        }
        //updateSiriVocabulary( )
    }
    
    func updateSiriVocabulary(){
        //Iniciando vocabulário da Siri através de um vetor de Strings - tasksNameArray
        INVocabulary.shared().setVocabularyStrings(NSOrderedSet(array: tasksNameArray), of: .workoutActivityName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor(white: 0.95, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
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
        updateTasksNameArray( )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTasks()
        
//        print("Cache.shared().tasks in TasksViewController: \(Cache.shared().tasks)")
    }
    
    //Loads all the active tasks from the dataBase
    func loadTasks(){
        manager.getTasks { (tasks) in
            Cache.shared().tasks = tasks

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



// MARK: Cell Protocol
extension TasksViewController: CellProtocol{
    
    func willStartTimer(cell: Cell){
        timeLogic.playPressed(task: cell.task)
        print("Play \(Cache.shared().tasks[cell.tag].name)")
    }
    
    func willStartTimerBySiri(cell: Cell){
        cell.startTimer()
        print("Play \(Cache.shared().tasks[cell.tag].name)")
    }
    
    func willStopTimer(cell: Cell){
        timeLogic.pausePressed(task: cell.task)
        print("Pause \(Cache.shared().tasks[cell.tag].name)")
    }
    
    func willStopTimerBySiri(cell: Cell){
        cell.stopTimer()
        print("Play \(Cache.shared().tasks[cell.tag].name)")
    }
    
    func timerDidTick(cell: Cell){
        cell.task.updateCurrentSessionDuration()
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
        
        if(myCell.task.isRunning) {
            myCell.initializeTimer()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        let task = Cache.shared().tasks[indexPath.row]
    
        cell.cellDelegate = self
        cell.task = task
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        
        //Verifica se a task dessa célula foi inicilizada por um comando da Siri
        if let acName = TasksViewController.startedActivityOnInit{
            if cell.taskLabel.text == acName{
                TasksViewController.startedActivityOnInit = nil
                willStartTimerBySiri(cell: cell)
            }
        }
        
        return cell
        }
    
    //Essa função está aqui por enquanto.... ela ativa um timer, mas deveria collapsar uma célula no futuro
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! Cell
        if cell.isOn == false{
            willStartTimerBySiri(cell: cell)
        }
        else{
            willStopTimerBySiri(cell: cell)
        }
    }
    
    //Swipe to delete a task
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            self.manager.delete(self.Cache.shared().tasks[indexPath.row].id, completion: {
//                OperationQueue.main.addOperation({
//                    self.Cache.shared().tasks.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                    self.tableView.isEditing=false
//                })
//            })
//        }
//        
//        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
//            // Preciso de uma tela de edit
//        }
//        
//        edit.backgroundColor = UIColor.blue
//        
//        return [delete, edit]
//    }
    
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


















