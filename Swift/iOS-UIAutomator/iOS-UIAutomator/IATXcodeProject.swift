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
    
    
    //MARK: - Compilation
    func getAppBuildLocation(block: (String) -> Void) {
        
        block("LOCATION")
    }
    
    func compileProject(target: String, configuration: String, block: (Bool) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var success = false
            var projectWorkspaceToggle = (self.isProject) ? "-project" : "-workspace"
            var buildCommand = "xcodebuild \(projectWorkspaceToggle) \(self.location) -scheme \(target) -configuration \(configuration) -sdk iphonesimulator"
            
            let outputLines = buildCommand.commandLineOutput().componentsSeparatedByString("\n")
            if outputLines[outputLines.count - 3] == "** BUILD SUCCEEDED **" {
                println("COMPILE SUCCESSFUL")
                success = true
            } else {
                println("COMPILE FAILED")
            }
            
            println("\(outputLines)")
            
            block(success)
            })
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            BOOL success = NO;
//            
//            NSString *buildSettingsCommand = [NSString stringWithFormat:@"xcodebuild %@ %@ -scheme %@ -configuration %@ -sdk iphonesimulator", ([url rangeOfString:@"xcodeproj"].location != NSNotFound) ? @"-project" : @"-workspace", url, target, configuration];
//            
//            NSArray *outputLines = [[buildSettingsCommand commandLineOutput] componentsSeparatedByString:@"\n"];
//            
//            if ([[outputLines objectAtIndex:([outputLines count] - 3)] isEqualToString:@"** BUILD SUCCEEDED **"]) {
//                success = YES;
//            }
//            
//            block(success);
//            });
        
        block(true)
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
    
    
    //MARK: - NSMenus
    func getMenuFromStringArray(array: String[]) -> NSMenu {
        var menu = NSMenu()
        for target in array {
            menu.addItemWithTitle(target, action: nil, keyEquivalent: "")
        }
        return menu
    }

}
