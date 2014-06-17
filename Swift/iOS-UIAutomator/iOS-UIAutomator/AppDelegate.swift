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
            
            //println("Callback recieved: \(simulators)")
            
            block(simulators)
        })
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

