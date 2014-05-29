//
//  IATAppDelegate.m
//  ProjectCompiler
//
//  Created by Jack Rostron on 29/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAppDelegate.h"
#import "NSString+CommandLineScript.h"


@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //NSLog(@"%@", [self loadXcodeProject]);
    
    NSLog(@"%@", [self getConfigurationsMenuForProject:[self loadXcodeProject]]);
}

/*
 ///<xctool.sh> -workspace AnyBet.xcworkspace -scheme AnyBet -sdk iphonesimulator
 //xcodebuild -workspace AnyBet.xcworkspace -scheme AnyBet -configuration Debug -sdk iphonesimulator
 //   /Users/Jack/Documents/Repos/BullOrBear/any-bet-ios/AnyBet/AnyBet.xcworkspace
 //   BUILT_PRODUCTS_DIR=
 //   EXECUTABLE_FOLDER_PATH=
 */

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
            
            [projectDictionary setObject:url.path forKey:@"url"];
        }
        
        NSString *projectLocation = ([[projectDictionary objectForKey:@"isProject"] boolValue]) ? [projectDictionary objectForKey:@"url"] : [[projectDictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"xcworkspace" withString:@"xcodeproj"];
        
        NSString *listTargetsCommand = [NSString stringWithFormat:@"xcodebuild -project %@ -list", projectLocation];
        NSString *parseableTargets = [listTargetsCommand commandLineOutput];
        
        NSArray *targets = [self getAvailableTargetsFromString:parseableTargets];
        [projectDictionary setObject:targets forKey:@"targets"];
        
        NSArray *configurations = [self getAvailableConfigurationsFromString:parseableTargets];
        [projectDictionary setObject:configurations forKey:@"configurations"];
    }
    
    return projectDictionary;
}

- (NSArray *)getAvailableTargetsFromString:(NSString *)parseableString
{
    NSRange r1 = [parseableString rangeOfString:@"Targets:"];
    NSRange r2 = [parseableString rangeOfString:@"Build Configurations:"];
    NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    
    NSString *targetSubstring = [parseableString substringWithRange:rSub];
    NSArray *targetLines = [targetSubstring componentsSeparatedByString:@"\n"];
    
    NSMutableArray *targets = [[NSMutableArray alloc] initWithCapacity:[targetLines count]];
    
    for (NSString *line in targetLines) {
        NSString *string = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (string.length > 0) {
            [targets addObject:string];
        }
    }
    
    return targets;
}

- (NSArray *)getAvailableConfigurationsFromString:(NSString *)parseableString
{
    NSRange r1 = [parseableString rangeOfString:@"Build Configurations:"];
    NSRange r2 = [parseableString rangeOfString:@"If no build configuration"];
    NSRange rSub = NSMakeRange(r1.location + r1.length, r2.location - r1.location - r1.length);
    
    NSString *targetSubstring = [parseableString substringWithRange:rSub];
    NSArray *targetLines = [targetSubstring componentsSeparatedByString:@"\n"];
    
    NSMutableArray *targets = [[NSMutableArray alloc] initWithCapacity:[targetLines count]];
    
    for (NSString *line in targetLines) {
        NSString *string = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (string.length > 0) {
            [targets addObject:string];
        }
    }
    
    return targets;
}

- (NSMenu *)getTargetsMenuForProject:(NSDictionary *)projectDictionary
{
    NSArray *targets = [projectDictionary objectForKey:@"targets"];
    NSMenu *menu = [[NSMenu alloc] init];
    
    for (NSString *target in targets) {
        [menu addItemWithTitle:target action:NULL keyEquivalent:@""];
    }
    
    return menu;
}

- (NSMenu *)getConfigurationsMenuForProject:(NSDictionary *)projectDictionary
{
    NSArray *configs = [projectDictionary objectForKey:@"configurations"];
    NSMenu *menu = [[NSMenu alloc] init];
    
    for (NSString *config in configs) {
        [menu addItemWithTitle:config action:NULL keyEquivalent:@""];
    }
    
    return menu;
}

/*
- (NSString *)getAppBuildLocationFromDictionary:(NSDictionary *)projectDictionary
{
    NSString *projectLocation = ([[projectDictionary objectForKey:@"isProject"] boolValue]) ? [projectDictionary objectForKey:@"url"] : [[projectDictionary objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"xcworkspace" withString:@"xcodeproj"];
    
    NSString *listTargetsCommand = [NSString stringWithFormat:@"xcodebuild -project %@ -list", projectLocation];
    NSString *parseableTargets = [listTargetsCommand commandLineOutput];
    
    return @"";
}
 */

- (BOOL)buildProjectFromDictionary:(NSDictionary *)projectDictionary
{
    //NSString *testBuildProject = @"xcodebuild -workspace /Users/Jack/Documents/Repos/BullOrBear/any-bet-ios/AnyBet/AnyBet.xcworkspace -scheme AnyBet -configuration Debug -sdk iphonesimulator";
    return FALSE;
}

@end
