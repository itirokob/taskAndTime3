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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = describedTask?.name
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


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
