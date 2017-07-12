//
//  StatisticsViewController.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, UISearchResultsUpdating {
    
    let manager = DataBaseManager.shared
    var tasksArray = [Task]()
    var sendingTask: Task?
    var filteredTasks = [Task]()
    
    let searchController = UISearchController(searchResultsController: nil)

    
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
        
        filteredTasks = tasksArray
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.barTintColor = UIColor(red: 34/255, green: 128/255, blue:171/255, alpha: 1)
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.placeholder =  "Search Activity"
        
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
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text!
        if searchText == "" {
            filteredTasks = tasksArray
        }else{
            filteredTasks = tasksArray.filter( { $0.name.lowercased().contains(searchText.lowercased()) } )
        }
        self.tableView.reloadData()
    }
}

extension StatisticsViewController : UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
        let task = filteredTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.getTimeString()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sendingTask = filteredTasks[indexPath.row]
        performSegue(withIdentifier: "showDescription", sender: self)
        
    }

}

