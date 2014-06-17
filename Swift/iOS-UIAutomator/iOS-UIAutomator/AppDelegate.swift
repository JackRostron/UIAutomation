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
            println("Callback recieved: \(simulators)")
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
        println("\(simulators)")
        
        //Dont need the UUID
        //Need to filter down by device model
        //Then add versions after
        
        /*
        "Resizable iPad (8.0 Simulator) (2CC45EF1-58B5-4DCF-8DD4-09D460D29ADA)",
        "Resizable iPhone (8.0 Simulator) (384BC216-8938-4089-8899-080511DFD8AA)",
        "iPad 2 (7.1 Simulator) (4317C240-49C6-42C5-BAD0-5F000A54A18F)",
        "iPad 2 (8.0 Simulator) (B93EFFDF-F7C6-4A5F-9B7F-C6E336A09645)",
        "iPad Air (7.1 Simulator) (BEFA280B-867F-4F94-9E51-E7E1D0A64BE5)",
        "iPad Air (8.0 Simulator) (07C1245A-6934-46AF-8579-1DD72DF14787)",
        "iPad Retina (7.1 Simulator) (FFE47F22-07C8-44A9-8DD7-5CD8B198ED5C)",
        "iPad Retina (8.0 Simulator) (35BFD334-2C04-4D3E-BF77-B881941E4A08)",
        "iPhone 4s (7.1 Simulator) (6D17B710-AD1D-437E-AE48-D06EC0B12D69)",
        "iPhone 4s (8.0 Simulator) (AC380F7D-60FB-450A-A88B-A3B82CFBB582)",
        "iPhone 5 (7.1 Simulator) (D54FD214-6B3A-440D-B454-F385721B6EA5)",
        "iPhone 5 (8.0 Simulator) (DA476DD7-8C3E-4BA0-B46F-91ACFFB21F4A)",
        "iPhone 5s (7.1 Simulator) (3B55F6D7-0594-47F3-AC5D-010388CADD06)",
        "iPhone 5s (8.0 Simulator) (8B7037CA-0A90-4ECC-BAF9-1E22F0991830)"
        */
        
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
            
            simulatorModelList.append(simulatorNameString)
        }
        
        println("Simulators: \(simulatorModelList)")
        
        return [];
    }
    
    func parseSimulatorsForMavericks(simulators: NSArray) -> NSArray {
        return []
    }
    //    - (void)getFormattedSimulatorListWithCompletion:(void(^)(NSArray *formattedSimualators))block
    //    {
    //    [self loadSimulatorVersionsWithCompletion:^(NSArray *simulators) {
    //    NSMutableArray *simulatorArray = [[NSMutableArray alloc] init];
    //
    //    for (int x = 0; x < [simulators count]; x++) {
    //    NSString *line = [simulators objectAtIndex:x];
    //    NSArray *brokenLine = [line componentsSeparatedByString:@" - "];
    //
    //    if (![simulatorArray containsObject:[brokenLine firstObject]]) {
    //    [simulatorArray addObject:[brokenLine firstObject]];
    //    }
    //    }
    //
    //    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:[simulators count]];
    //
    //    for (int x = 0; x < [simulatorArray count]; x++) {
    //    NSDictionary *simulatorSetup = @{@"device" : [simulatorArray objectAtIndex:x],
    //    @"versions" : [self getVersionsForSimulatorDeviceType:[simulatorArray objectAtIndex:x] fromSimulatorList:simulators]};
    //
    //    [finalArray addObject:simulatorSetup];
    //    }
    //
    //    block(finalArray);
    //    }];
    //    }
    
    func getVersionsForSimulatorDeviceTypeFromSimulatorList(device: String, list: NSArray) {
        
    }
    //    - (NSArray *)getVersionsForSimulatorDeviceType:(NSString *)deviceString fromSimulatorList:(NSArray *)simulators
    //    {
    //    NSMutableArray *versionsAvailable = [[NSMutableArray alloc] init];
    //
    //    for (int x = 0; x < [simulators count]; x++) {
    //    NSString *line = [simulators objectAtIndex:x];
    //    NSArray *brokenLine = [line componentsSeparatedByString:@" - "];
    //    
    //    if ([[brokenLine firstObject] isEqualToString:deviceString]) {
    //    [versionsAvailable addObject:[brokenLine lastObject]];
    //    }
    //    }
    //    
    //    return versionsAvailable;
    //    }
    
}

