//
//  AppDelegate.swift
//  iOS-UIAutomator
//
//  Created by Jack Rostron on 16/06/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

import Cocoa
import Dispatch

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
        
        self.getFormattedSimulatorListWithCompletion({(simulators: NSArray) in
            
            println("Callback recieved")
            for var x = 0; x < simulators.count; x++ {
                var simulator: IATSimulator = simulators.objectAtIndex(x) as IATSimulator
                println("\(simulator.name)")
            }
            
            })
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(theApplication: NSApplication!) -> Bool {
        return true
    }
    
    
    //MARK: - System Checks
    func isRunningYosemiteOrLater() -> Bool {
        //println("Output of OS check: \(NSProcessInfo.processInfo().operatingSystemVersionString)") //Human readable - documentation says not to parse
        
        //WARNING NEED TO VERIFY THIS WILL WORK ON MAVERICKS - public in 10.10, private in 10.9
        if NSProcessInfo.processInfo().operatingSystemVersion.majorVersion >= 10 {
            return true
        } else {
            return false
        }
    }
    
    
    //MARK: - Simulator
    func simulatorSelectedFromMenu(menuItem: NSMenuItem) {
        
    }
    //    - (void)simulatorSelectedFromMenu:(id)sender
    //    {
    //    NSMenuItem *selectedMenuItem = sender;
    //
    //    for (NSMenuItem *menuItem in self.simulatorMenu.menu.itemArray) {
    //    [menuItem setState:NSOffState];
    //    if (menuItem.submenu) {
    //    for (NSMenuItem *subMenuItem in menuItem.submenu.itemArray) {
    //    [subMenuItem setState:NSOffState];
    //    }
    //    }
    //    }
    //
    //    [selectedMenuItem setState:NSOnState];
    //    [self.simulatorMenu selectItemWithTitle:selectedMenuItem.menu.title];
    //
    //    self.selectedSimulatorString = [NSString stringWithFormat:@"%@ - Simulator - %@", selectedMenuItem.menu.title, selectedMenuItem.title];
    //    }
    
    func getSimulatorMenu() {
        
    }
    //    - (void)getSimulatorMenu
    //    {
    //    [self getFormattedSimulatorListWithCompletion:^(NSArray *formattedSimualators) {
    //    NSMenu *compiledMenu = [[NSMenu alloc] init];
    //
    //    for (NSDictionary *simulator in formattedSimualators) {
    //    NSMenuItem *simulatorMenu = [[NSMenuItem alloc] initWithTitle:[simulator objectForKey:@"device"] action:NULL keyEquivalent:@""];
    //    NSArray *versionList = [simulator objectForKey:@"versions"];
    //
    //    NSMenu *versionMenu = [[NSMenu alloc] initWithTitle:[simulator objectForKey:@"device"]];
    //    for (NSString *version in versionList) {
    //    [versionMenu addItemWithTitle:version action:@selector(simulatorSelectedFromMenu:) keyEquivalent:@""];
    //    }
    //
    //    [simulatorMenu setSubmenu:versionMenu];
    //    [compiledMenu addItem:simulatorMenu];
    //    }
    //
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //    self.simulatorMenu.menu = compiledMenu;
    //    [self.simulatorMenu setEnabled:YES];
    //    [[self.simulatorMenu.menu itemAtIndex:0] setState:NSOnState];
    //    [self simulatorSelectedFromMenu:[[self.simulatorMenu.menu itemAtIndex:0].submenu itemAtIndex:0]];
    //    });
    //    }];
    //    }
    
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
            if self.isRunningYosemiteOrLater() {
                block(self.parseSimulatorsForYosemite(simulators))
            } else {
                block(self.parseSimulatorsForMavericks(simulators))
            }
            })
    }
    
    func parseSimulatorsForYosemite(simulators: NSArray) -> NSArray {
        //Get unique simulator models
        var simulatorModelList = String[]()
        
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
        
        //Get version numbers for each simulator
        var finalSimulatorArray = IATSimulator[]()
        
        for var x = 0; x < simulatorModelList.count; x++ {
            let device = simulatorModelList[x] as String
            let versions = self.getVersionsForSimulatorDeviceTypeFromSimulatorList(device, list: simulators)
            let simulator = IATSimulator(name: device, versions: versions)
            
            finalSimulatorArray.append(simulator)
        }
        
        return finalSimulatorArray;
    }
    
    func parseSimulatorsForMavericks(simulators: NSArray) -> NSArray {
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
}

