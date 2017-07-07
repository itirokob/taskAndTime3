//
//  TasksViewController.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 6/28/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit
import Intents

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CellProtocol {
    let manager = DataBaseManager.shared

    let timeLogic = TimeLogic.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addTaskField: UITextField!
    
    var tasksArray = [Task]()
    var tasksNameArray: [String] = []
    public static var startedActivityOnInit:String?

    var refresh: UIRefreshControl!
    
    func updateTasksNameArray(){
        if tasksArray.count > 0{
            for i in 0...(tasksArray.count - 1){
                tasksNameArray.append(tasksArray[i].name)
            }
        }
        updateSiriVocabulary( )
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
        updateSiriVocabulary( )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTasks()
    }
    
    func willStartTimer(cell: Cell){
        timeLogic.playPressed(task: tasksArray[cell.tag])
        print("Play \(tasksArray[cell.tag].name)")
    }
    
    func willStopTimer(cell: Cell){
        tasksArray[cell.tag] = timeLogic.pausePressed(task: tasksArray[cell.tag])
        print("Pause \(tasksArray[cell.tag].name)")
    }
    
    func timerDidTick(cell: Cell){
        tasksArray[cell.tag].updateSessionDuration()
    }
    
    //Loads all the active tasks from the dataBase
    func loadTasks(){
        manager.getTasks { (tasks) in
            self.tasksArray = tasks

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
            let dates = [Date]()
            let times = [Int]()
            let uuid = UUID().uuidString
            
            let task = Task(name: addTaskField.text!, isSubtask: -1, tasksDates: dates, tasksTimes: times, totalTime: 0, isActive: 1, id: uuid)
            
            manager.saveTask(task: task, completion: { (task2, error) in
                OperationQueue.main.addOperation({
                    self.tableView.reloadData()
                })
            })
            self.dismissKeyboard()
            self.addTaskField.text = ""
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
        
        let task = tasksArray[indexPath.row]
        
        cell.delegate = self
        
        cell.timeLabelValue = task.getTotalTime()
        
        cell.taskLabel.text = task.name
                
        cell.tag = indexPath.row
        
        
        //PINTA DE AZUL TESTE
        if let acName = TasksViewController.startedActivityOnInit{
            print("Not Null \(acName)")
            self.view.backgroundColor = .blue
        }
        else{
            print("Not started by Siri")
        }

        return cell
    }
    
    //Swipe to delete a task
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.manager.delete(self.tasksArray[indexPath.row].id, completion: {
                OperationQueue.main.addOperation({
                    self.tasksArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.isEditing=false
                })
            })
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            // Preciso de uma tela de edit e
        }
        
        edit.backgroundColor = UIColor.blue
        
        return [delete, edit]
    }
    
    public func startActivityBySiri(activityName: String?){
        
        for task in tasksArray{
            if task.id == activityName!{
                task.isRunning = true
            }
        }
    }

}
