//
//  IATAppDelegate.m
//  JavaScriptCommunicator
//
//  Created by Jack Rostron on 22/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAppDelegate.h"

///<xctool.sh> -workspace AnyBet.xcworkspace -scheme AnyBet -sdk iphonesimulator
//xcodebuild -workspace AnyBet.xcworkspace -scheme AnyBet -configuration Debug -sdk iphonesimulator
//   /Users/Jack/Documents/Repos/BullOrBear/any-bet-ios/AnyBet/AnyBet.xcworkspace
//   BUILT_PRODUCTS_DIR=
//   EXECUTABLE_FOLDER_PATH=

typedef enum {
    kInstrumentsCommandListTree,
} kInstrumentsCommand;


@interface IATAppDelegate ()
//@property (nonatomic, strong)
@end


@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    [self sendCommandToInstruments:kInstrumentsCommandListTree];
}

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"%@", url);
}

- (BOOL)sendCommandToInstruments:(kInstrumentsCommand)command
{
    NSString *commandString;
    
    switch (command) {
        case kInstrumentsCommandListTree:
            commandString = @"ListTree";
            break;
            break;
    }
    
    if (commandString) {
        NSError *error;
        
        ///Users/JackRostron/Desktop/UIAutomation/JavaScriptCommunicator/Bash/wibble.txt
        
        [commandString writeToFile:@"/Users/JackRostron/Desktop/UIAutomation/JavaScriptCommunicator/Bash/wibble.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
        return (error) ? NO : YES;
    }
    
    return NO;
}

@end
