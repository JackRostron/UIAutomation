//
//  AppDelegate.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 16/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa
import Dispatch

class AppDelegate: NSObject, NSApplicationDelegate, NSAlertDelegate {
    
    @IBOutlet var window: NSWindow
    
    @IBOutlet var openProjectButton: NSButton
    @IBOutlet var targetMenu: NSPopUpButton
    @IBOutlet var configurationMenu: NSPopUpButton
    @IBOutlet var simulatorMenu: NSPopUpButton
    @IBOutlet var runButton: NSButton
    @IBOutlet var captureButton: NSButton
    
    @IBOutlet var screenshotImageView: NSImageView
    @IBOutlet var listTreeOutlineView: NSOutlineView
    
    var selectedSimulatorString: String?
    
    var modalAlert: UnknownTaskAlert = UnknownTaskAlert(windowNibName: "UnknownTaskAlert")
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        
        self.getSimulatorMenu()
        //self.showAlertWithTitle("Compiling")
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication!) -> Bool {
        return true
    }
    
    
    //MARK: - System Checks
    func isXcode6orGreater() -> Bool {
        //THIS SHOULD WORK - NEEDS CONFIRMING ON MAVERICKS THOUGH
        let xcodeVersionCommand = "xcodebuild -version"
        let xcodeOutput = xcodeVersionCommand.commandLineOutput()
        let trimToVersionStart = xcodeOutput.stringByReplacingOccurrencesOfString("Xcode ", withString: "")
        let xcodeMajorNumber = trimToVersionStart.substringToIndex(1).toInt()
        return (xcodeMajorNumber >= 6) ? true : false
    }
    
    
    //MARK: - Simulator
    func simulatorSelectedFromMenu(menuItem: NSMenuItem) {
        println("Simulator selected from menu")
        
        var selectedMenuItem = menuItem
        
        for menuItem:NSMenuItem! in self.simulatorMenu.menu.itemArray {
            menuItem.state = NSOffState
            if menuItem.submenu {
                for var x = 0; x < menuItem.submenu.itemArray.count; x++ {
                    var submenu = menuItem.submenu.itemArray[x] as NSMenuItem
                    submenu.state = NSOffState
                }
            }
        }
        
        selectedMenuItem.state = NSOnState
        self.simulatorMenu.selectItemWithTitle(selectedMenuItem.menu.title)
        
        //THIS NEEDS CONFIRMING - UNSURE WHETHER THIS WILL ACTUALLY WORK - MIGHT NEED TO STORE AND RETRIEVE UUID OF SIMULATORS
        self.selectedSimulatorString = "\(selectedMenuItem.menu.title) (\(selectedMenuItem.title) Simulator)"
    }
    
    func getSimulatorMenu() {
        self.getFormattedSimulatorListWithCompletion({(simulators: NSArray) in
            
            var compiledMenu = NSMenu()
            
            for var x = 0; x < simulators.count; x++ {
                var simulator = simulators.objectAtIndex(x) as IATSimulator
                var menuItem = NSMenuItem(title: simulator.name, action: nil, keyEquivalent: "")
                
                var versionMenu = NSMenu(title: simulator.name)
                for var y = 0; y < simulator.versions.count; y++ {
                    versionMenu.addItemWithTitle(simulator.versions[y], action: Selector("simulatorSelectedFromMenu:"), keyEquivalent: "")
                }
                
                menuItem.submenu = versionMenu
                compiledMenu.addItem(menuItem)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.simulatorMenu.menu = compiledMenu
                self.simulatorMenu.enabled = true
                self.simulatorMenu.itemAtIndex(0).state = NSOnState
                self.simulatorSelectedFromMenu(self.simulatorMenu.menu.itemAtIndex(0).submenu.itemAtIndex(0))
            })
            
            })
    }
    
    func loadSimulatorVersionsWithCompletion(block: (NSArray) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let simulatorCommand = "instruments -w printSimulators"
            let unparsedSimulators = simulatorCommand.commandLineOutput()
            let simulatorLines = unparsedSimulators.componentsSeparatedByString("\n")
            var simulators = String[]()
            
            for line in simulatorLines {
                var lineNSString: NSString = line;
                if ((lineNSString.containsString("iPhone") || lineNSString.containsString("iPad")) && lineNSString.containsString(" Simulator) ")) {
                    simulators.append(line)
                }
            }
            
            block(simulators)
        }
    }
    
    func getFormattedSimulatorListWithCompletion(block: (NSArray) -> Void) {
        self.loadSimulatorVersionsWithCompletion({(simulators: NSArray) in
            if self.isXcode6orGreater() {
                block(self.parseSimulatorsForXcode6(simulators))
            } else {
                block(self.parseSimulatorsForXcode5(simulators))
            }
            })
    }
    
    func parseSimulatorsForXcode6(simulators: NSArray) -> NSArray {
        var simulatorModelList = String[]() //Get unique simulator models
        
        for var x = 0; x < simulators.count; x++ {
            var simulator: AnyObject = simulators.objectAtIndex(x)
            var simulatorComponents = simulator.componentsSeparatedByString(" (")
            var simulatorNameString: String = ""
            
            if simulatorComponents.count >= 3 { //Last 2 components will be "(UUID)" and "* Simulator)"
                for var y = 0; y < (simulatorComponents.count - 2); y++ {
                    if y != 0 {
                        simulatorNameString += " ("
                    }
                    simulatorNameString += (simulatorComponents[y] as String)
                }
            } else {
                return []; //Error out, return nothing
            }
            
            if !simulatorModelList.contains(simulatorNameString) {
                simulatorModelList.append(simulatorNameString)
            }
        }
        
        var finalSimulatorArray = IATSimulator[]() //Get version numbers for each simulator
        
        for var x = 0; x < simulatorModelList.count; x++ {
            let device = simulatorModelList[x] as String
            let versions = self.getVersionsForSimulatorDeviceTypeFromSimulatorList(device, list: simulators)
            let simulator = IATSimulator(name: device, versions: versions)
            
            finalSimulatorArray.append(simulator)
        }
        
        return finalSimulatorArray;
    }
    
    func parseSimulatorsForXcode5(simulators: NSArray) -> NSArray {
        /*
        (lldb) po deviceString
        iPhone Retina (3.5-inch)
        
        (lldb) po simulators
        iPhone Retina (3.5-inch) - Simulator - iOS 7.1,
        iPhone Retina (4-inch) - Simulator - iOS 7.1,
        iPhone Retina (4-inch 64-bit) - Simulator - iOS 7.1,
        iPad - Simulator - iOS 7.1,
        iPad Retina - Simulator - iOS 7.1,
        iPad Retina (64-bit) - Simulator - iOS 7.1
        */
        return []
    }
    
    func getVersionsForSimulatorDeviceTypeFromSimulatorList(device: String, list: NSArray) -> String[] {
        var versionArray = String[]()
        
        for var x = 0; x < list.count; x++ {
            var line = list.objectAtIndex(x) as String
            
            if line.hasPrefix("\(device) (") {
                var versionPrefix = line.stringByReplacingOccurrencesOfString("\(device) (", withString: "")
                var versionNumber = versionPrefix.substringToIndex(3)
                versionArray.append(versionNumber)
            }
        }
        
        return versionArray
    }
    
    
    //MARK: - Modal alerts
    func showAlertWithTitle(title: String) {
        self.modalAlert.title.stringValue = title
        self.modalAlert.progressIndicator.startAnimation(nil)
        NSApp.beginSheet(self.modalAlert.window, modalForWindow: self.window, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)
    }
    
    
    /*
    - (void)setupCompilingSheet
    {
    NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 400, 20))];
    [progressIndic setStyle:NSProgressIndicatorBarStyle];
    [progressIndic startAnimation:nil];
    
    self.compilingAlert = [NSAlert alertWithMessageText:@"Compiling app" defaultButton:@"Use" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [self.compilingAlert setAccessoryView:progressIndic];
    
    NSButton *button = [[self.compilingAlert buttons] objectAtIndex:0];
    [button setHidden:YES];
    }
    
    - (void)dismissCompileSheet
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp endSheet:self.compilingAlert.window];
    });
    }
    
    - (void)setupLaunchingAppSheet
    {
    NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 400, 20))];
    [progressIndic setStyle:NSProgressIndicatorBarStyle];
    [progressIndic startAnimation:nil];
    
    self.launchingAppAlert = [NSAlert alertWithMessageText:@"Launching app" defaultButton:@"Use" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [self.launchingAppAlert setAccessoryView:progressIndic];
    
    NSButton *button = [[self.launchingAppAlert buttons] objectAtIndex:0];
    [button setHidden:YES];
    }
    
    - (void)dismissLaunchingAppSheet
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp endSheet:self.launchingAppAlert.window];
    });
    }
    
    - (void)setupCaptureSheet
    {
    NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 400, 20))];
    [progressIndic setStyle:NSProgressIndicatorBarStyle];
    [progressIndic startAnimation:nil];
    
    self.capturingScreenshotAlert = [NSAlert alertWithMessageText:@"Capturing screenshot" defaultButton:@"Use" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [self.capturingScreenshotAlert setAccessoryView:progressIndic];
    
    NSButton *button = [[self.capturingScreenshotAlert buttons] objectAtIndex:0];
    [button setHidden:YES];
    }
    
    - (void)dismissCaptureSheet
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp endSheet:self.capturingScreenshotAlert.window];
    });
    }
    
    - (void)didEndSheet:(id)modalSheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
    {
    [modalSheet orderOut: nil];
    }
    */
}













