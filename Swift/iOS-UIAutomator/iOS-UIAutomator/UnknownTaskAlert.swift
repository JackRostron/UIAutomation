//
//  UnknownTaskAlert.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 18/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

class UnknownTaskAlert: NSWindowController {
    
    @IBOutlet var title: NSTextField
    @IBOutlet var progressIndicator: NSProgressIndicator

    init(window: NSWindow?) {
        super.init(window: window)
    }
    
    convenience init(windowNibName: String!) {
        self.init(window: nil)
        NSBundle.mainBundle().loadNibNamed(windowNibName, owner: self, topLevelObjects: nil)
    }
}
