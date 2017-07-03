//
//  Cell.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 7/2/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation
import UIKit

class Cell:UITableViewCell{
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    //State Constraints
    @IBOutlet var stateAConstraints: [NSLayoutConstraint]!
    @IBOutlet var stateBConstraints: [NSLayoutConstraint]!
    
    //State Variable
    private var state:Bool = true
    
    func collapse(){
        print("in here!!!")
        
        state = !state
        
        if state == true{
            for c in stateAConstraints{ c.isActive = true}
            for c in stateBConstraints{ c.isActive = false}
        }
        else{
            for c in stateBConstraints{ c.isActive = true}
            for c in stateAConstraints{ c.isActive = false}
        }
        
    }
    
}
