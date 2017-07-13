//
//  ActivityDescriptionViewController.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class ActivityDescriptionViewController: UIViewController {
    
    var describedTask : Task!
    var selectedRow : Int = -1
    @IBOutlet weak var graphView: LineGraphView!
    @IBOutlet weak var nodataWarning: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = describedTask.name
        graphView.lineGraphDataSource = self as LineGraphProtocol
        
        if describedTask.sessions.count == 0{
            nodataWarning.text = "No data to display"
        } else{
            nodataWarning.text = ""
        }
        selectedRow = -1
        descriptionLabel.text = ""
    }

}

// Implementing the table View Delegates and Data source
// it shows the description of a task (describedTask), passed by the previous View
extension ActivityDescriptionViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return describedTask.sessions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)
        
        //Get and formatt the sessin time
        let sessionDate = describedTask.sessions[indexPath.row].startDate
        let dateFormate = DateFormatter()
        dateFormate.dateStyle = .medium
        dateFormate.timeStyle = .short
        
        cell.textLabel?.text = dateFormate.string(from: sessionDate)
        let durationInSeconds = describedTask.sessions[indexPath.row].durationInSeconds
        cell.detailTextLabel?.text = getTimeString(time: durationInSeconds)
        
        //cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        descriptionLabel.text = "Selected Session Time: \(getTimeString(time: describedTask.sessions[indexPath.row].durationInSeconds))"
        graphView.reloadData()
    }
    
    // Format a given time to mm:ss
    func getTimeString(time: Int) -> String{
        
        let minutes :Int = time / 60
        let seconds :Int = time - 60*minutes
        
        return "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }

}

// Implementing the Graph View data soure protocol
extension ActivityDescriptionViewController : LineGraphProtocol{

    // This method needs to return a [Float] with the time of the sessions of the describedTask
    func getGraphValueArray() -> [Float] {
        
        var dataPoints = [Float]()
        print("task \(describedTask)'s sessions: \(describedTask.sessions)")
        for session in describedTask.sessions{
            dataPoints.append(Float(session.durationInSeconds))
        }
        
        return dataPoints
    }
    
    // Returns the selected row of the table view, to be highlighted on the graph view
    func getSelectedRow() -> Int {
        return selectedRow
    }
    
}
