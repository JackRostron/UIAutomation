//
//  NSString+CommandLineScript.m
//  RunScriptTest
//
//  Created by Jack Rostron on 02/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "NSString+CommandLineScript.h"

@implementation NSString (CommandLineScript)

- (NSString *)commandLineOutput
{
    NSTask *task = [[NSTask alloc] init];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", self]];
    [task setStandardOutput: pipe];
    [task launch];
    
    return [[NSString alloc] initWithData:[file readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

@end
