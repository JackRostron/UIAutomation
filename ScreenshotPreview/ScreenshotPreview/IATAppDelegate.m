//
//  IATAppDelegate.m
//  ScreenshotPreview
//
//  Created by Jack Rostron on 22/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAppDelegate.h"
#import "NSString+CommandLineScript.h"
#import "IATJavascriptCommunicator.h"

@interface IATAppDelegate ()

@property (nonatomic, assign) BOOL isProjectRunning;

@property (nonatomic, strong) IBOutlet NSButton *openProjectButton;
@property (nonatomic, strong) IBOutlet NSPopUpButton *targetMenu;
@property (nonatomic, strong) IBOutlet NSPopUpButton *configurationMenu;

@property (nonatomic, strong) IBOutlet NSButton *runButton;

@property (nonatomic, strong) NSDictionary *xcodeProject;

@end


@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.isProjectRunning = NO;
    
    [self.targetMenu setEnabled:NO];
    [self.configurationMenu setEnabled:NO];
    [self.runButton setEnabled:NO];
}

#pragma mark - IBActions
- (IBAction)openNewProject:(id)sender
{
    [self loadXcodeProjectWithCompletionHandler:^(NSDictionary *project) {
        
        self.xcodeProject = project;
        
        if (self.xcodeProject) {
            self.targetMenu.menu = [self getTargetsMenuForProject:self.xcodeProject];
            self.configurationMenu.menu = [self getConfigurationsMenuForProject:self.xcodeProject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.targetMenu setEnabled:YES];
                [self.configurationMenu setEnabled:YES];
                [self.runButton setEnabled:YES];
            });
            
        } else {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"There was an error opening the Xcode project. Please try again.";
            [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {}];
        }
    }];
}

- (IBAction)run:(id)sender
{
    __block NSString *appBuildLocation = [self getAppBuildLocationWithDirectory:[self.xcodeProject objectForKey:@"url"]
                                                                      andTarget:self.targetMenu.selectedItem.title
                                                              withConfiguration:self.configurationMenu.selectedItem.title];
    
    [self buildAppWithDirectory:[self.xcodeProject objectForKey:@"url"]
                      andTarget:self.targetMenu.selectedItem.title
               andConfiguration:self.configurationMenu.selectedItem.title
                 withCompletion:^(BOOL success) {
                     
                     if (success) {
                         [self launchInstrumentsWithAppInDirectory:appBuildLocation];
                         
                     } else {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             NSAlert *alert = [[NSAlert alloc] init];
                             alert.messageText = @"There was an error compiling the Xcode project.\n\nCheck you can compile correctly in Xcode and ensure you are opening the .xcworkspace if required.";
                             [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {}];
                         });
                     }
                 }];
}

#pragma mark - Launch project in Instruments
- (void)launchInstrumentsWithAppInDirectory:(NSString *)directory
{
    NSLog(@"Launching Instruments...");
}

#pragma mark - JavaScript Communicator
- (IBAction)screenshotButtonPressed:(id)sender
{
    if (self.isProjectRunning) {
        [IATJavascriptCommunicator sendCommandToInstruments:kInstrumentsCommandListTree throughDirectory:@""];
        
    } else {
        NSLog(@"Project not running - handle error");
    }
}

#pragma mark - Retrieve simulators


#pragma mark - Project Compiler
- (void)loadXcodeProjectWithCompletionHandler:(void(^)(NSDictionary *project))block
{
    __block NSMutableDictionary *projectDictionary;
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"xcodeproj", @"xcworkspace"]];
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            
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
        
        block(projectDictionary);
    }];
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

- (NSString *)getAppBuildLocationWithDirectory:(NSString *)url andTarget:(NSString *)target withConfiguration:(NSString *)configuration;
{
    NSString *buildSettingsCommand = [NSString stringWithFormat:@"xcodebuild %@ %@ -scheme %@ -configuration %@ -showBuildSettings", ([url rangeOfString:@"xcodeproj"].location != NSNotFound) ? @"-project" : @"-workspace", url, target, configuration];
    
    NSArray *outputLines = [[buildSettingsCommand commandLineOutput] componentsSeparatedByString:@"\n"];
    
    NSString *buildDirectory;
    NSString *appLocation;
    
    for (NSString *line in outputLines) {
        if ([line rangeOfString:@" BUILT_PRODUCTS_DIR"].location != NSNotFound) {
            buildDirectory = [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"BUILT_PRODUCTS_DIR = " withString:@""];
            break;
        }
    }
    
    for (NSString *line in outputLines) {
        if ([line rangeOfString:@" EXECUTABLE_FOLDER_PATH"].location != NSNotFound) {
            appLocation = [[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"EXECUTABLE_FOLDER_PATH = " withString:@""];
            break;
        }
    }
    
    return [buildDirectory stringByAppendingPathComponent:appLocation];
}

- (BOOL)buildAppWithDirectory:(NSString *)url andTarget:(NSString *)target withConfiguration:(NSString *)configuration
{
    NSString *buildSettingsCommand = [NSString stringWithFormat:@"xcodebuild %@ %@ -scheme %@ -configuration %@", ([url rangeOfString:@"xcodeproj"].location != NSNotFound) ? @"-project" : @"-workspace", url, target, configuration];
    
    NSArray *outputLines = [[buildSettingsCommand commandLineOutput] componentsSeparatedByString:@"\n"];
    
    if ([[outputLines objectAtIndex:([outputLines count] - 3)] isEqualToString:@"** BUILD SUCCEEDED **"]) {
        return YES;
    }
    
    return NO;
}

- (void)buildAppWithDirectory:(NSString *)url andTarget:(NSString *)target andConfiguration:(NSString *)configuration withCompletion:(void(^)(BOOL success))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL success = NO;
        
        NSString *buildSettingsCommand = [NSString stringWithFormat:@"xcodebuild %@ %@ -scheme %@ -configuration %@", ([url rangeOfString:@"xcodeproj"].location != NSNotFound) ? @"-project" : @"-workspace", url, target, configuration];
        
        NSArray *outputLines = [[buildSettingsCommand commandLineOutput] componentsSeparatedByString:@"\n"];
        
        if ([[outputLines objectAtIndex:([outputLines count] - 3)] isEqualToString:@"** BUILD SUCCEEDED **"]) {
            success = YES;
        }
        
        block(success);
    });
}


@end
