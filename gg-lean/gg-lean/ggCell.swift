//
//  ggCell.swift
//  gg-lean
//
//  Created by Giovani Nascimento Pereira on 03/07/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import UIKit

class ggCell: UITableViewCell {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    //CustomView Constraints
    @IBOutlet weak var customViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var customViewBottomConstraint: NSLayoutConstraint!
    
    //State Var
    var collapsed : Bool = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collapse(){
        
        collapsed = !collapsed
        
        if collapsed == true{
            customViewTopConstraint.constant    = 100
            customViewBottomConstraint.constant = -200
        }
        else{
            customViewTopConstraint.constant    = 10
            customViewBottomConstraint.constant = 10
        }
    }
    
    
}
