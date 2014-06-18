//
//  IATSimulator.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 18/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

class IATSimulator: NSObject {
    
    var name: String
    var versions: String[]
    
    init(name: String, versions: String[]) {
        self.name = name
        self.versions = versions
    }
   
}
