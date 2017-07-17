//
//  ActivityDescriptionViewController.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 10/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class ActivityDescriptionViewController: UIViewController, SessionsObserver {
    
    var describedTask : Task!
    var selectedRow : Int = -1
    @IBOutlet weak var graphView: LineGraphView!
    @IBOutlet weak var nodataWarning: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        describedTask.sessionsObservers.append(self)
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeFromObservers()
    }
    
    func removeFromObservers() {
        var index: Int?
        
        for i in 0..<describedTask.sessionsObservers.count {
            if let viewController = (describedTask.sessionsObservers[i] as? UIViewController), viewController == self {
                index = i
            }
        }
        if let index = index {
            describedTask.sessionsObservers.remove(at: index)
        }
        
    }
    
    func newData() {
        self.tableView.reloadData()
        graphView.setNeedsDisplay()
        
        if describedTask.sessions.count == 0{
            nodataWarning.text = "No data to display"
        } else{
            nodataWarning.text = ""
        }
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
        let session = describedTask.sessions[indexPath.row]
        let sessionDate = session.startDate
        let dateFormate = DateFormatter()
        dateFormate.dateStyle = .medium
        dateFormate.timeStyle = .short
        
        cell.textLabel?.text = dateFormate.string(from: sessionDate)
        cell.detailTextLabel?.text = getTimeString(time: session.durationInSeconds)
        
        //Creating Selection Style to tableView cell
        cell.selectedBackgroundView = UIView ()
        cell.selectedBackgroundView?.backgroundColor = backCellBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        descriptionLabel.text = "Selected Session Time: \(getTimeString(time: describedTask.sessions[indexPath.row].durationInSeconds))"
        graphView.reloadData()
    }
    
    // Format a given time to mm:ss
    func getTimeString(time: Int) -> String{
        let hours: Int = time/3600
        
        let minutes :Int = (time % 3600) / 60
        let seconds = time - (3600 * hours) - (60 * minutes)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}

// Implementing the Graph View data soure protocol
extension ActivityDescriptionViewController : LineGraphProtocol{

    // This method needs to return a [Float] with the time of the sessions of the describedTask
    func getGraphValueArray() -> [Float] {
        
        var dataPoints = [Float]()
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
