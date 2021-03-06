//
//  StatisticsViewController.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

let backCellBlue : UIColor = UIColor(red: 34/255, green: 128/255, blue:171/255, alpha: 1)

class StatisticsViewController: UIViewController, UISearchResultsUpdating, CacheObserver {
    
    var sendingTask: Task?
    var filteredTasks = [Task]()
    
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tableView: UITableView!
    
    var refresh: UIRefreshControl!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Cache.shared().observers.append(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeFromObservers()
    }
    
    func removeFromObservers() {
        var index: Int?
        
        for i in 0..<Cache.shared().observers.count {
            if let viewController = (Cache.shared().observers[i] as? UIViewController), viewController == self {
                index = i
            }
        }
        if let index = index {
            Cache.shared().observers.remove(at: index)
        }

    }
    
    func newData() {        
        filteredTasks = Cache.shared().tasks.filter{ $0.isRunning }
        self.tableView.reloadData()
    }

    //Loads all the active tasks from the dataBase
    func loadTasks(){
        Cache.shared().updateTasks(active: false){ (tasks) in
            
            self.filteredTasks = tasks
            
            OperationQueue.main.addOperation({
                self.tableView.reloadData()
                self.refresh.endRefreshing()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        filteredTasks = Cache.shared().tasks.filter{ $0.isRunning }
        

        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.barTintColor = UIColor(red: 34/255, green: 128/255, blue:171/255, alpha: 1)
        searchController.searchBar.backgroundColor = .clear
        searchController.searchBar.tintColor = .white
        searchController.searchBar.isTranslucent = false
        searchController.searchBar.placeholder =  "Search Activity"
        
        //Pull to refresh
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(StatisticsViewController.loadTasks), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresh)
        
        loadTasks()
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
            filteredTasks = Cache.shared().tasks
        }else{
            filteredTasks = Cache.shared().tasks.filter( { $0.name.lowercased().contains(searchText.lowercased()) } )
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
        
        //Creating Selection Style
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = backCellBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sendingTask = filteredTasks[indexPath.row]
        performSegue(withIdentifier: "showDescription", sender: self)
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
    }

}

