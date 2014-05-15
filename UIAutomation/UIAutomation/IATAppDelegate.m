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

@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    //[[IATRunner sharedRunner] testWeCanTalkToInstruments];
    
    
    IATApp *myApp = [[IATApp alloc] initWithName:@"PowaTag-Code-Coverage"
                                     andBundleID:@"com.powa.PowaTag-CC"
                                      atLocation:@"/Users/JackRostron/Library/Developer/Xcode/DerivedData/PowaTag-beyjcveresnrxbcuyxgpplxujlnh/Build/Products/QA-iphonesimulator/PowaTag-Code-Coverage.app"];
    
    NSLog(@"%@", myApp.name);
    
    [[IATRunner sharedRunner] runTestForApp:myApp];
    
}

@end
