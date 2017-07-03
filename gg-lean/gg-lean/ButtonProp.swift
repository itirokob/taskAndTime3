//
//  ButtonProp.swift
//  gg-lean
//
//  Created by Bianca Yoshie Itiroko on 7/2/17.
//  Copyright © 2017 Bepid. All rights reserved.
//

import Foundation
import UIKit

class ButtonProp{
    public var button:UIButton
    public var playPauseState:Int
    
    init(button:UIButton, playPauseState:Int) {
        self.button = button
        self.playPauseState = playPauseState
    }
}
