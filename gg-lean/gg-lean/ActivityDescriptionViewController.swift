//
//  ActivityDescriptionViewController.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class ActivityDescriptionViewController: UIViewController {
    
    var describedTask : Task?
    @IBOutlet weak var graphView: LineGraphView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = describedTask?.name
        graphView.lineGraphDataSource = self as LineGraphProtocol
    }

}

// Implementing the table View Delegates and Data source
// it shows the description of a task (describedTask), passed by the previous View
extension ActivityDescriptionViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (describedTask?.sessions.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
        
        let sessionDate = (describedTask?.sessions[indexPath.row].startDate)!
        let dateFormate = DateFormatter()
        dateFormate.dateStyle = .medium
        dateFormate.timeStyle = .medium
        
        cell.textLabel?.text = dateFormate.string(from: sessionDate)
        cell.detailTextLabel?.text = String(describing: describedTask?.sessions[indexPath.row].durationInSeconds)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

}

// Implementing the Graph View data soure protocol
extension ActivityDescriptionViewController : LineGraphProtocol{

    // his method needs to return a [Float] with the time of the sessions of the describedTask
    func getGraphValueArray() -> [Float] {
        return [10, 20, 30, 12, 15, 33, 50, 3, 10, 22, 23, 38,10, 20, 50, 55, 51, 30, 12, 15, 33, 50, 3, 10, 22, 23, 38,10, 20, 30, 12, 15, 33, 50, 3, 10, 22, 23, 38]
    }
    
}
