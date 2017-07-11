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

class TasksViewController: UIViewController{
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
        //updateSiriVocabulary( )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadTasks()
    }
    
    //Loads all the active tasks from the dataBase
    func loadTasks(){
        manager.getTasks { (tasks) in
            self.tasksArray = tasks

            OperationQueue.main.addOperation({ 
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                //self.updateTasksNameArray()
            })
        }
    }
    
    //Action from the done button (which replaces the "return" button from the keyboard)
    @IBAction func doneAction(_ sender: Any) {
        if addTaskField.text == "" || (addTaskField.text?.isEmpty)!{
            self.dismissKeyboard()
        } else {
            //We want tasksDates and tasksTimes empty arrays because it will only receive values when the pause button is reached
            
            let task = Task(name: addTaskField.text!, isSubtask: -1, totalTime: 0, isActive: 1, id: UUID().uuidString)
            
            manager.saveTask(task: task, completion: { (task2, error) in
                OperationQueue.main.addOperation({
                    self.tasksArray.insert(task2!, at: 0)
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
                    self.tableView.endUpdates()
                })
            })
            self.dismissKeyboard()
            self.addTaskField.text = ""
            
            //updateTasksNameArray()
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
        timeLogic.playPressed(task: tasksArray[cell.tag])
        print("Play \(tasksArray[cell.tag].name)")
    }
    
    func willStartTimerBySiri(cell: Cell){
        cell.initiateActivity()
        print("Play \(tasksArray[cell.tag].name)")
    }
    
    func willStopTimer(cell: Cell){
        tasksArray[cell.tag] = timeLogic.pausePressed(task: tasksArray[cell.tag])
        print("Pause \(tasksArray[cell.tag].name)")
    }
    
    func willStopTimerBySiri(cell: Cell){
        cell.stopActivity()
        print("Play \(tasksArray[cell.tag].name)")
    }
    
    func timerDidTick(cell: Cell){
        tasksArray[cell.tag].updateSessionDuration()
    }

}



// MARK: Table View Extensions
extension TasksViewController: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:Cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
        let task = tasksArray[indexPath.row]
        
        cell.delegate = self
        cell.timeLabelValue = task.getTotalTime()
        cell.taskLabel.text = task.name
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
//            self.manager.delete(self.tasksArray[indexPath.row].id, completion: {
//                OperationQueue.main.addOperation({
//                    self.tasksArray.remove(at: indexPath.row)
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }
        
        let completeAction = SwipeAction(style: .default , title: "Done") { action, indexPath in
            self.tasksArray[indexPath.row].isActive = 0
            self.manager.saveTask(task: self.tasksArray[indexPath.row], completion: { (task, error) in
                OperationQueue.main.addOperation({
                    self.tasksArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.tableView.isEditing = false
                })
            })
        }
        
        // customize the action appearance
        completeAction.image = UIImage(named: "Complete")
        completeAction.backgroundColor = UIColor.green
        
        return [completeAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .fill
        options.transitionStyle = .border
        return options
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        //guard orientation == .right else { return nil }
//        
//        if (orientation == .right) {
//        
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            // handle action by updating model with deletion
//        }
//        
//        var options = SwipeTableOptions()
//        options.expansionStyle = SwipeExpansionStyle.selection
//        
//        // customize the action appearance
//        deleteAction.image = UIImage(named: "delete")
//        
//        return [deleteAction]
//        } else {
//            let otherAction = SwipeAction(style: .default, title: "Ahhhh") { action, indexPath in
//                // handle action by updating model with deletion
//            }
//            
//            let secondAction = SwipeAction(style: .default, title: "Blehhh") { action, indexPath in
//                // handle action by updating model with deletion
//            }
//            
//            secondAction.backgroundColor = UIColor.yellow
//            
//            return [otherAction, secondAction]
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
//        var options = SwipeTableOptions()
//            options.expansionStyle = .selection
//        options.transitionStyle = orientation == .left ? .reveal : .border
//        return options
//    }

}
