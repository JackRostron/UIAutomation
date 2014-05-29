//
//  IATAppDelegate.m
//  ProjectCompiler
//
//  Created by Jack Rostron on 29/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAppDelegate.h"
#import "NSString+CommandLineScript.h"

@interface IATAppDelegate ()

@property (nonatomic, strong) NSDictionary *selectedProjectDictionary;

@end



@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSLog(@"%@", [self loadXcodeProject]);
}

- (NSDictionary *)loadXcodeProject
{
    NSMutableDictionary *projectDictionary;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"xcodeproj", @"xcworkspace"]];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        
        projectDictionary = [[NSMutableDictionary alloc] init];
        
        for (NSURL *url in [panel URLs]) {
            
            if ([url.absoluteString rangeOfString:@"xcodeproj"].location != NSNotFound) {
                [projectDictionary setObject:@1 forKey:@"isProject"];
            } else {
                [projectDictionary setObject:@0 forKey:@"isProject"];
            }
            
            [projectDictionary setObject:url forKey:@"url"];
        }
        
    }
    
    return projectDictionary;
}

@end
