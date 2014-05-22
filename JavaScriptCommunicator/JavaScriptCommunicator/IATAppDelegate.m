//
//  IATAppDelegate.m
//  JavaScriptCommunicator
//
//  Created by Jack Rostron on 22/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAppDelegate.h"

@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"%@", url);
}

@end
