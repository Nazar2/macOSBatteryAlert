//
//  AlertVC.swift
//  BatteryAlert
//
//  Created by Nazar Pallaev on 26/06/2018.
//  Copyright © 2018 Nazar Pallaev. All rights reserved.
//

import Cocoa

protocol AlertVCProtocol:NSObjectProtocol {
    func alertVCProtocolCloseClicked()
}

class AlertVC: NSViewController {

    @IBOutlet weak var textFieldOutlet: NSTextField!
    weak var delegate:AlertVCProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldOutlet.stringValue = "Hey"
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        delegate?.alertVCProtocolCloseClicked()
    }
}
