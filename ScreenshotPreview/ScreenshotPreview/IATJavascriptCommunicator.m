//
//  IATJavascriptCommunicator.m
//  JavaScriptCommunicator
//
//  Created by Jack Rostron on 29/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATJavascriptCommunicator.h"

@implementation IATJavascriptCommunicator

+ (BOOL)sendCommandToInstruments:(kInstrumentsCommand)command throughDirectory:(NSString *)directory
{
    NSString *commandString;
    
    switch (command) {
        case kInstrumentsCommandListTree:
            commandString = @"UIATarget.localTarget().logElementTree()";
            break;
            break;
    }
    
    if (commandString) {
        NSError *error;
        [commandString writeToFile:directory atomically:YES encoding:NSUTF8StringEncoding error:&error];
        return (error) ? NO : YES;
    }
    
    return NO;
}

@end
