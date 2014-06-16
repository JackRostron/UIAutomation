//
//  NSString+CommandLineScript.swift
//  SwiftCommandLine
//
//  Created by Jack Rostron on 16/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

extension String {
    
    func commandLineOutput() -> String {
        var task = NSTask()
        var pipe = NSPipe.pipe()
        var fileHandle = pipe.fileHandleForReading
        
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", self]
        task.standardOutput = pipe
        task.launch()
        
        var data = fileHandle.readDataToEndOfFile()
        return NSString(data: data, encoding: NSUTF8StringEncoding)
    }
    
}