//
//  Array+Contains.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 18/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

extension Array {
    
    func contains(object: AnyObject!) -> Bool {
        if (self.isEmpty) {
            return false
        }
        
        let array: NSArray = self.bridgeToObjectiveC();
        return array.containsObject(object)
    }
    
}