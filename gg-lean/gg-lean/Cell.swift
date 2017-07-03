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
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    func collapse(){
        print("in here!!!")
        if let heightConstraint = cellHeight{
            print(heightConstraint.isActive)
            heightConstraint.isActive = !heightConstraint.isActive
            print("Not nil")
            print(heightConstraint.isActive)
        }
    }
    
}
