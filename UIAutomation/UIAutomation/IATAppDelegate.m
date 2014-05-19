//
//  IATAppDelegate.m
//  UIAutomation
//
//  Created by Jack Rostron on 15/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAppDelegate.h"
#import "IATRunner.h"
#import "IATApp.h"
#import "IATAvailableTargetsManager.h"
#import "IATSimulatorDevice.h"

@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    //[[IATRunner sharedRunner] testWeCanTalkToInstruments];
    
    
    IATApp *myApp = [[IATApp alloc] initWithName:@"PowaTag-Code-Coverage"
                                     andBundleID:@"com.powa.PowaTag-CC"
                                      atLocation:@"/Users/JackRostron/Library/Developer/Xcode/DerivedData/PowaTag-beyjcveresnrxbcuyxgpplxujlnh/Build/Products/QA-iphonesimulator/PowaTag-Code-Coverage.app"];
    
    NSLog(@"%@", myApp.name);
    
    //IATSimulatorDevice *simulator = [[IATSimulatorDevice alloc] initWithVersion:@"6.0"];
    //[[IATRunner sharedRunner] runTestForApp:myApp];
    //[[IATRunner sharedRunner] runTestForApp:myApp onSimulator:simulator];
    
    [[IATAvailableTargetsManager sharedManager] availableTargetMenu];
    
    
    
//    NSLog(@"%@", [[IATAvailableTargetsManager sharedManager] simulators]);
//    
//    for (int x = 0; x < [[[IATAvailableTargetsManager sharedManager] simulators] count]; x++) {
//        
//        IATSimulatorDevice *device = [[IATSimulatorDevice alloc] initWithVersion:[[[IATAvailableTargetsManager sharedManager] simulators] objectAtIndex:x]];
//        
//        NSLog(@"%@", [device getCommandLineVersionWithSimulatorDevice:kiOSSimulatoriPad andSize:kSimulatorSizeiPad andBitRate:kSimulatorProcessorBitRate64]);
//        
//        NSLog(@"%@", [device getCleanLocationWithBitRate:kSimulatorProcessorBitRate64]);
//        
//    }
    
}

@end
