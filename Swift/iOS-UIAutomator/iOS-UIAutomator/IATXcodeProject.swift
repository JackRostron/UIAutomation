//
//  IATXcodeProject.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 18/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

class IATXcodeProject: NSObject {
    
    var name: String;
    var location: String;
    var targets: String[]
    var configurations: String[]
    var isProject: Bool
    
    
    //MARK: - Init
    init(name: String, location: String, targets: String[], configurations: String[], isProject: Bool) {
        self.name = name;
        self.location = IATXcodeProject.removeProjectURLPrefix(location)
        self.targets = targets;
        self.configurations = configurations;
        self.isProject = isProject;
        
        super.init();
    }
    
    convenience init(projectLocation: String) {
        let isProj = (projectLocation.hasSuffix(".xcodeproj")) ? true: false //Check filetype
        let finalProjectLocation = IATXcodeProject.removeProjectURLPrefix(projectLocation)
        
        let commandLineProjectLocation = finalProjectLocation.stringByReplacingOccurrencesOfString(".xcworkspace", withString: ".xcodeproj")
        let listTargetsCommand = "xcodebuild -project \(commandLineProjectLocation) -list"
        let parseableTargets = listTargetsCommand.commandLineOutput()
        
        let targets = IATXcodeProject.getContentsOfLinesBetweenStrings(parseableTargets, string1: "Targets:", string2: "Build Configurations:")
        let configurations = IATXcodeProject.getContentsOfLinesBetweenStrings(parseableTargets, string1: "Build Configurations:", string2: "If no build configuration")
        
        self.init(name: projectLocation.lastPathComponent, location: finalProjectLocation, targets: targets, configurations: configurations, isProject: isProj)
    }
    
    
    //MARK: - Parsers & Setup
    class func removeProjectURLPrefix(location: String) -> String {
        if location.hasPrefix("file:///") {
            return location.stringByReplacingOccurrencesOfString("file:///", withString: "/")
        } else {
            return location;
        }
    }
    
    class func getContentsOfLinesBetweenStrings(fullText: String, string1: String, string2: String) -> String[] {
        let range1 = fullText.bridgeToObjectiveC().rangeOfString(string1)
        let range2 = fullText.bridgeToObjectiveC().rangeOfString(string2)
        let rangeOfContents = NSMakeRange(range1.location + range1.length, range2.location - range1.location - range1.length)
        
        let targetSubstring = fullText.bridgeToObjectiveC().substringWithRange(rangeOfContents)
        let targetLines = targetSubstring.componentsSeparatedByString("\n")
        
        var targets = String[]()
        
        for line in targetLines {
            let targetLine = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if !targetLine.isEmpty {
                targets.append(targetLine)
            }
        }
        
        return targets;
    }

}




