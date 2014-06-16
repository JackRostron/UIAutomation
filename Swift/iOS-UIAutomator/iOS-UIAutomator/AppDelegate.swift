//
//  AppDelegate.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 16/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow
    
    @IBOutlet var openProjectButton: NSButton
    @IBOutlet var targetMenu: NSPopUpButton
    @IBOutlet var configurationMenu: NSPopUpButton
    @IBOutlet var simulatorMenu: NSPopUpButton
    @IBOutlet var runButton: NSButton
    @IBOutlet var captureButton: NSButton
    
    @IBOutlet var screenshotImageView: NSImageView
    @IBOutlet var listTreeOutlineView: NSOutlineView

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

