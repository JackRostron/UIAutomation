//
//  IATJavascriptCommunicator.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 16/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

enum kInstrumentsCommand: Int {
    case ListTree
}

class IATJavascriptCommunicator: NSObject {
    
    func sendCommandToInstrumentsThroughDirectory(command: kInstrumentsCommand, directory: String) {
        
        var commandString = ""
        
        switch (command) {
        case kInstrumentsCommand.ListTree:
            println("ListTree Command")
            commandString = "UIATarget.localTarget().logElementTree()"
            break
        }
        
        if (!commandString.isEmpty) {
            var error : NSError?
            commandString.writeToFile(directory, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
        }
    }
    
}
