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

@interface IATAppDelegate () <NSAlertDelegate>

@property (nonatomic, weak) IBOutlet NSButton *openProjectButton;
@property (nonatomic, weak) IBOutlet NSPopUpButton *targetMenu;
@property (nonatomic, weak) IBOutlet NSPopUpButton *configurationMenu;
@property (nonatomic, weak) IBOutlet NSPopUpButton *simulatorMenu;
@property (nonatomic, weak) IBOutlet NSButton *runButton;
@property (nonatomic, weak) IBOutlet NSButton *captureButton;

@property (nonatomic, weak) IBOutlet NSImageView *screenshotImageView;
@property (nonatomic, weak) IBOutlet NSOutlineView *listTreeOutlineView;

@property (nonatomic, strong) NSDictionary *xcodeProject;
@property (nonatomic, strong) NSString *selectedSimulatorString;
@property (nonatomic, strong) NSString *temporaryDirectory;

@property (nonatomic, strong) NSAlert *compilingAlert;
@property (nonatomic, strong) NSAlert *launchingAppAlert;
@property (nonatomic, strong) NSAlert *capturingScreenshotAlert;

@end


@implementation IATAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Register for communication
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    
    self.temporaryDirectory = [self createTemporaryDirectory];
    
    [self.targetMenu setEnabled:NO];
    [self.configurationMenu setEnabled:NO];
    [self.simulatorMenu setEnabled:NO];
    [self.runButton setEnabled:NO];
    [self.captureButton setEnabled:NO];
    
    [self setupCompilingSheet];
    [self setupLaunchingAppSheet];
    [self setupCaptureSheet];
    [self getSimulatorMenu];
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
                
                if (![self.simulatorMenu isEnabled] && [self.simulatorMenu.itemArray count] > 1) {
                    [self.simulatorMenu setEnabled:YES];
                }
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
    [self.compilingAlert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    
    [self getAppBuildLocationWithDirectory:[self.xcodeProject objectForKey:@"url"]
                                 andTarget:self.targetMenu.selectedItem.title
                          andConfiguration:self.configurationMenu.selectedItem.title
                            withCompletion:^(NSString *location) {
                                
                                [self buildAppWithDirectory:[self.xcodeProject objectForKey:@"url"]
                                                  andTarget:self.targetMenu.selectedItem.title
                                           andConfiguration:self.configurationMenu.selectedItem.title
                                             withCompletion:^(BOOL success) {
                                                 
                                                 if (success) {
                                                     [self dismissCompileSheet];
                                                     [self launchInstrumentsWithAppInDirectory:location];
                                                     
                                                 } else {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         NSAlert *alert = [[NSAlert alloc] init];
                                                         alert.messageText = @"There was an error compiling the Xcode project.\n\nCheck you can compile correctly in Xcode and ensure you are opening the .xcworkspace if required.";
                                                         [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {}];
                                                     });
                                                 }
                                             }];
                            }];
}

#pragma mark - Instruments
- (void)launchInstrumentsWithAppInDirectory:(NSString *)directory
{
    [self terminateSimulator];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.launchingAppAlert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    });
    
    //New locations
    NSString *editedBashScriptLocation = [self.temporaryDirectory stringByAppendingPathComponent:@"fileUpdated.sh"];
    NSString *editedIATUtilitiesLocation = [self.temporaryDirectory stringByAppendingPathComponent:@"IATUtilities.js"];
    NSString *editedLoopJavascriptLocation = [self.temporaryDirectory stringByAppendingPathComponent:@"loop.js"];
    NSString *fileUpdatedBashLocation = [self.temporaryDirectory stringByAppendingPathComponent:@"listTreeCommandComplete.sh"];
    NSString *simulatorLaunchedBaseLocation = [self.temporaryDirectory stringByAppendingPathComponent:@"simulatorFinishedLaunching.sh"];
    NSString *outputFilePath = [self.temporaryDirectory stringByAppendingPathComponent:@"output.js"];
    
    //Output file
    NSString *outputFileContents = @"";
    [outputFileContents writeToFile:outputFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    //Bash script
    NSString *bashScript = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fileUpdated" ofType:@".sh"] encoding:NSUTF8StringEncoding error:nil];
    NSString *bashScriptStringToReplace = @"IATSUITEOUTPUTFILEPATH";
    bashScript = [bashScript stringByReplacingOccurrencesOfString:bashScriptStringToReplace withString:outputFilePath];
    
    //IAT Utilities - Does not need modifying
    NSString *iatUtilitiesJavascript = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"IATUtilities" ofType:@".js"] encoding:NSUTF8StringEncoding error:nil];
    
    //ListTreeCommandComplete - Does not need modifying
    NSString *listTreeCommandCompleteBash = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"listTreeCommandComplete" ofType:@".sh"] encoding:NSUTF8StringEncoding error:nil];
    
    //Simulator launched - does not need modifying
    NSString *simulatorLaunchedBash = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"simulatorFinishedLaunching" ofType:@".sh"] encoding:NSUTF8StringEncoding error:nil];
    
    //Loop Javascript
    NSString *loopJavascript = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loop" ofType:@".js"] encoding:NSUTF8StringEncoding error:nil];
    NSString *loopJavascriptBashStringToReplace = @"IATSUITEFILEUPDATEDBASHSCRIPT";
    NSString *simulatorFinishedLaunchingStringToReplace = @"IATSUITESIMULATORLAUNCHCOMPLETE";
    NSString *communicatorStringToReplace = @"IATSUITELISTTREECOMPLETE";
    loopJavascript = [loopJavascript stringByReplacingOccurrencesOfString:loopJavascriptBashStringToReplace withString:[NSString stringWithFormat:@"%@", editedBashScriptLocation]];
    loopJavascript = [loopJavascript stringByReplacingOccurrencesOfString:bashScriptStringToReplace withString:[NSString stringWithFormat:@"%@", outputFilePath]];
    loopJavascript = [loopJavascript stringByReplacingOccurrencesOfString:simulatorFinishedLaunchingStringToReplace withString:[NSString stringWithFormat:@"%@", simulatorLaunchedBaseLocation]];
    loopJavascript = [loopJavascript stringByReplacingOccurrencesOfString:communicatorStringToReplace withString:[NSString stringWithFormat:@"%@", fileUpdatedBashLocation]];
    
    //Write to temporary directory - need to remove these when finished
    [bashScript writeToFile:editedBashScriptLocation atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [iatUtilitiesJavascript writeToFile:editedIATUtilitiesLocation atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [listTreeCommandCompleteBash writeToFile:fileUpdatedBashLocation atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [simulatorLaunchedBash writeToFile:simulatorLaunchedBaseLocation atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [loopJavascript writeToFile:editedLoopJavascriptLocation atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    //Allow bash scripts to be executed
    NSString *baseExecutableCommand = [NSString stringWithFormat:@"chmod 700 %@", editedBashScriptLocation];
    [baseExecutableCommand commandLineOutput];
    
    baseExecutableCommand = [NSString stringWithFormat:@"chmod 700 %@", simulatorLaunchedBaseLocation];
    [baseExecutableCommand commandLineOutput];
    
    baseExecutableCommand = [NSString stringWithFormat:@"chmod 700 %@", fileUpdatedBashLocation];
    [baseExecutableCommand commandLineOutput];
    
    //UIAResultsPath output
    NSString *resultsOutputPath = [self.temporaryDirectory stringByAppendingPathComponent:@"Output/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:resultsOutputPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    //Trace template
    NSString *traceTemplateLocation = [[NSBundle mainBundle] pathForResource:@"Automation" ofType:@".tracetemplate"];
    
    //Create Instruments command
    NSString *instrumentsCommand = [NSString stringWithFormat:@"instruments -w '%@' -t '%@' -D %@ '%@' -e UIASCRIPT '%@' -e UIARESULTSPATH '%@'", self.selectedSimulatorString, traceTemplateLocation, [self.temporaryDirectory stringByAppendingString:@"/"], directory, editedLoopJavascriptLocation, resultsOutputPath];
    
    //Dismiss compile alert
    [self dismissCompileSheet];
    
    NSLog(@"%@", instrumentsCommand);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //NSLog(@"%@", [instrumentsCommand commandLineOutput]);
        [instrumentsCommand commandLineOutput];
    });
}

#pragma mark - Temporary Directory
- (NSString *)createTemporaryDirectory //Create a unique directory in the system temporary directory for storing plist output
{
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil]) {
        return nil;
    }
    return path;
}

#pragma mark - JavaScript Communicator
- (IBAction)screenshotButtonPressed:(id)sender
{
    [self.capturingScreenshotAlert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:nil];
    [IATJavascriptCommunicator sendCommandToInstruments:kInstrumentsCommandListTree throughDirectory:[self.temporaryDirectory stringByAppendingPathComponent:@"output.js"]];
}

#pragma mark - Check Xcode version
- (BOOL)isXcode6orGreater {
    NSString *xcodeVersionCommand = @"xcodebuild -version";
    NSString *xcodeOutput = [xcodeVersionCommand commandLineOutput];
    NSString *trimToVersionStart = [xcodeOutput stringByReplacingOccurrencesOfString:@"Xcode " withString:@""];
    NSString *xcodeMajorNumber = [trimToVersionStart substringToIndex:1];
    return ([xcodeMajorNumber integerValue] >= 6) ? YES : NO;
}

#pragma mark - Retrieve simulators
- (void)simulatorSelectedFromMenu:(id)sender
{
    NSMenuItem *selectedMenuItem = sender;
    
    for (NSMenuItem *menuItem in self.simulatorMenu.menu.itemArray) {
        [menuItem setState:NSOffState];
        if (menuItem.submenu) {
            for (NSMenuItem *subMenuItem in menuItem.submenu.itemArray) {
                [subMenuItem setState:NSOffState];
            }
        }
    }
    
    [selectedMenuItem setState:NSOnState];
    [self.simulatorMenu selectItemWithTitle:selectedMenuItem.menu.title];
    
    if ([self isXcode6orGreater]) {
        //self.selectedSimulatorString = "\(selectedMenuItem.menu.title) (\(selectedMenuItem.title) Simulator)"
        self.selectedSimulatorString = [NSString stringWithFormat:@"%@ (%@ Simulator)", selectedMenuItem.menu.title, selectedMenuItem.title];
    } else {
        self.selectedSimulatorString = [NSString stringWithFormat:@"%@ - Simulator - %@", selectedMenuItem.menu.title, selectedMenuItem.title];
    }
}

- (void)getSimulatorMenu
{
    [self getFormattedSimulatorListWithCompletion:^(NSArray *formattedSimualators) {
        NSMenu *compiledMenu = [[NSMenu alloc] init];
        
        for (NSDictionary *simulator in formattedSimualators) {
            NSMenuItem *simulatorMenu = [[NSMenuItem alloc] initWithTitle:[simulator objectForKey:@"device"] action:NULL keyEquivalent:@""];
            NSArray *versionList = [simulator objectForKey:@"versions"];
            
            NSMenu *versionMenu = [[NSMenu alloc] initWithTitle:[simulator objectForKey:@"device"]];
            for (NSString *version in versionList) {
                [versionMenu addItemWithTitle:version action:@selector(simulatorSelectedFromMenu:) keyEquivalent:@""];
            }
            
            [simulatorMenu setSubmenu:versionMenu];
            [compiledMenu addItem:simulatorMenu];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.simulatorMenu.menu = compiledMenu;
            [self.simulatorMenu setEnabled:YES];
            [[self.simulatorMenu.menu itemAtIndex:0] setState:NSOnState];
            [self simulatorSelectedFromMenu:[[self.simulatorMenu.menu itemAtIndex:0].submenu itemAtIndex:0]];
        });
    }];
}

- (void)loadSimulatorVersionsWithCompletion:(void(^)(NSArray *simulators))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *availableSimulators = @"instruments -w printSimulators";
        NSString *unparsedSimulators = [availableSimulators commandLineOutput];
        NSArray *sdkLines = [unparsedSimulators componentsSeparatedByString:@"\n"];
        
        NSMutableArray *simulators = [[NSMutableArray alloc] init];
        
        if ([self isXcode6orGreater]) {
            for (NSString *line in sdkLines) {
                if ([line rangeOfString:@" Simulator) ("].location != NSNotFound) {
                    [simulators addObject:line];
                }
            }
            
        } else {
            for (NSString *line in sdkLines) {
                if ([line rangeOfString:@" - Simulator - "].location != NSNotFound && [line rangeOfString:@"iPhone - Simulator - "].location == NSNotFound) {
                    [simulators addObject:line];
                }
            }
        }
        
        block(simulators);
    });
}

- (void)getFormattedSimulatorListWithCompletion:(void(^)(NSArray *formattedSimualators))block
{
    [self loadSimulatorVersionsWithCompletion:^(NSArray *simulators) {
        
        if ([self isXcode6orGreater]) {
            NSLog(@"Xcode 6 or greater, terminating");
            NSArray *xcode6Simulators = [self xcode6GetDeviceModelList:simulators];
            
            NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:[simulators count]];
            
            for (int x = 0; x < [xcode6Simulators count]; x++) {
                NSDictionary *simulatorSetup = @{@"device" : [xcode6Simulators objectAtIndex:x],
                                                 @"versions" : [self xcode6GetVersionsForSimulatorDeviceType:[xcode6Simulators objectAtIndex:x] fromSimulatorList:simulators]};
                
                [finalArray addObject:simulatorSetup];
            }
            
            block(finalArray);
            
        } else {
            NSMutableArray *simulatorArray = [[NSMutableArray alloc] init];
            
            for (int x = 0; x < [simulators count]; x++) {
                NSString *line = [simulators objectAtIndex:x];
                NSArray *brokenLine = [line componentsSeparatedByString:@" - "];
                
                if (![simulatorArray containsObject:[brokenLine firstObject]]) {
                    [simulatorArray addObject:[brokenLine firstObject]];
                }
            }
            
            NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:[simulators count]];
            
            for (int x = 0; x < [simulatorArray count]; x++) {
                NSDictionary *simulatorSetup = @{@"device" : [simulatorArray objectAtIndex:x],
                                                 @"versions" : [self getVersionsForSimulatorDeviceType:[simulatorArray objectAtIndex:x] fromSimulatorList:simulators]};
                
                [finalArray addObject:simulatorSetup];
            }
            
            block(finalArray);
        }
    }];
}

- (NSArray *)getVersionsForSimulatorDeviceType:(NSString *)deviceString fromSimulatorList:(NSArray *)simulators
{
    NSMutableArray *versionsAvailable = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [simulators count]; x++) {
        NSString *line = [simulators objectAtIndex:x];
        NSArray *brokenLine = [line componentsSeparatedByString:@" - "];
        
        if ([[brokenLine firstObject] isEqualToString:deviceString]) {
            [versionsAvailable addObject:[brokenLine lastObject]];
        }
    }
    
    return versionsAvailable;
}


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

- (void)getAppBuildLocationWithDirectory:(NSString *)url andTarget:(NSString *)target andConfiguration:(NSString *)configuration withCompletion:(void(^)(NSString *location))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *buildSettingsCommand = [NSString stringWithFormat:@"xcodebuild %@ %@ -scheme %@ -configuration %@ -sdk iphonesimulator -showBuildSettings", ([url rangeOfString:@"xcodeproj"].location != NSNotFound) ? @"-project" : @"-workspace", url, target, configuration];
        
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
        
        block([buildDirectory stringByAppendingPathComponent:appLocation]);
    });
}

- (void)buildAppWithDirectory:(NSString *)url andTarget:(NSString *)target andConfiguration:(NSString *)configuration withCompletion:(void(^)(BOOL success))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL success = NO;
        
        NSString *buildSettingsCommand = [NSString stringWithFormat:@"xcodebuild %@ %@ -scheme %@ -configuration %@ -sdk iphonesimulator", ([url rangeOfString:@"xcodeproj"].location != NSNotFound) ? @"-project" : @"-workspace", url, target, configuration];
        
        NSArray *outputLines = [[buildSettingsCommand commandLineOutput] componentsSeparatedByString:@"\n"];
        
        if ([[outputLines objectAtIndex:([outputLines count] - 3)] isEqualToString:@"** BUILD SUCCEEDED **"]) {
            success = YES;
        }
        
        block(success);
    });
}

#pragma mark - Monitor changes in Instruments output directory
- (void)monitorForListTreeResultWithCompletion:(void(^)(NSString *imageURL, NSString *plist))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL locatedContents = NO;
        while (locatedContents != YES) {
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.temporaryDirectory stringByAppendingString:@"/Output/Run 1/"] error:nil];
            if ([contents count] > 2) {
                locatedContents = YES;
                
                NSString *plist;
                NSString *imageURL;
                for (NSString *fileName in contents) {
                    if ([fileName rangeOfString:@".plist"].location != NSNotFound) {
                        plist = fileName;
                    } else if ([fileName rangeOfString:@".png"].location != NSNotFound) {
                        imageURL = fileName;
                    }
                }
                block(imageURL, plist);
            }
        }
    });
}

- (void)clearContentsOfTemporaryDirectory
{
    [[NSFileManager defaultManager] removeItemAtPath:[self.temporaryDirectory stringByAppendingString:@"/Output/Run 1"] error:nil];
}

#pragma mark - Terminate Simulator
- (void)terminateSimulator
{
    NSString *quitSimulatorCommand = @"osascript -e 'tell app \"iPhone Simulator\" to quit'";
    [quitSimulatorCommand commandLineOutput];
}

#pragma mark - Modal Views
- (void)setupCompilingSheet
{
    NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 400, 20))];
    [progressIndic setStyle:NSProgressIndicatorBarStyle];
    [progressIndic startAnimation:nil];
    
    self.compilingAlert = [NSAlert alertWithMessageText:@"Compiling app" defaultButton:@"Use" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [self.compilingAlert setAccessoryView:progressIndic];
    
    NSButton *button = [[self.compilingAlert buttons] objectAtIndex:0];
    [button setHidden:YES];
}

- (void)dismissCompileSheet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp endSheet:self.compilingAlert.window];
    });
}

- (void)setupLaunchingAppSheet
{
    NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 400, 20))];
    [progressIndic setStyle:NSProgressIndicatorBarStyle];
    [progressIndic startAnimation:nil];
    
    self.launchingAppAlert = [NSAlert alertWithMessageText:@"Launching app" defaultButton:@"Use" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [self.launchingAppAlert setAccessoryView:progressIndic];
    
    NSButton *button = [[self.launchingAppAlert buttons] objectAtIndex:0];
    [button setHidden:YES];
}

- (void)dismissLaunchingAppSheet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp endSheet:self.launchingAppAlert.window];
    });
}

- (void)setupCaptureSheet
{
    NSProgressIndicator *progressIndic = [[NSProgressIndicator alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 400, 20))];
    [progressIndic setStyle:NSProgressIndicatorBarStyle];
    [progressIndic startAnimation:nil];
    
    self.capturingScreenshotAlert = [NSAlert alertWithMessageText:@"Capturing screenshot" defaultButton:@"Use" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
    [self.capturingScreenshotAlert setAccessoryView:progressIndic];
    
    NSButton *button = [[self.capturingScreenshotAlert buttons] objectAtIndex:0];
    [button setHidden:YES];
}

- (void)dismissCaptureSheet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp endSheet:self.capturingScreenshotAlert.window];
    });
}

- (void)didEndSheet:(id)modalSheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [modalSheet orderOut: nil];
}

#pragma mark - Application Delegate
- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self terminateSimulator];
    [[NSFileManager defaultManager] removeItemAtPath:self.temporaryDirectory error:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)handleURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    
    if ([[url lastPathComponent] isEqualToString:@"SimulatorDidLaunch"]) {
        [self dismissLaunchingAppSheet];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.captureButton setEnabled:YES];
        });
        
    } else if ([[url lastPathComponent] isEqualToString:@"ListTree"]) {
        [self monitorForListTreeResultWithCompletion:^(NSString *imageURL, NSString *plist) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSImage *screenshot = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Output/Run 1/%@", self.temporaryDirectory, imageURL]];
                [self.screenshotImageView setImage:screenshot];
                
                NSDictionary *listTreePlist = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/Output/Run 1/%@", self.temporaryDirectory, plist]];
                self.currentListTree = [[NSMutableArray alloc] initWithArray:[[[listTreePlist objectForKey:@"All Samples"] lastObject] objectForKey:@"children"]];
                [self.listTreeOutlineView expandItem:nil expandChildren:YES];
                
                [self clearContentsOfTemporaryDirectory];
                [self dismissCaptureSheet];
            });
        }];
    }
}

#pragma mark - Xcode 6 fixes
- (NSArray *)xcode6GetDeviceModelList:(NSArray *)simulators
{
    NSMutableArray *simulatorArray = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [simulators count]; x++) {
        NSString *line = [simulators objectAtIndex:x];
        NSArray *brokenLine = [line componentsSeparatedByString:@" ("];
        NSMutableString *simulatorName = [[NSMutableString alloc] initWithString:@""];
        
        if (brokenLine.count >= 3) {
            for (int y = 0; y < (brokenLine.count - 2); y++) {
                if (y != 0) {
                    [simulatorName appendString:@" ("];
                }
                [simulatorName appendString:[brokenLine objectAtIndex:y]];
            }
        }
        
        if (![simulatorArray containsObject:simulatorName]) {
            [simulatorArray addObject:simulatorName];
        }
    }
    return simulatorArray;
}

- (NSArray *)xcode6GetVersionsForSimulatorDeviceType:(NSString *)deviceString fromSimulatorList:(NSArray *)simulators
{
    NSMutableArray *versionsAvailable = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [simulators count]; x++) {
        NSString *line = [simulators objectAtIndex:x];
        
        if ([line hasPrefix:[NSString stringWithFormat:@"%@ (", deviceString]]) {
            NSString *versionPrefix = [line stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@ (", deviceString] withString:@""];
            NSString *versionNumber = [versionPrefix substringToIndex:3];
            [versionsAvailable addObject:versionNumber];
        }
    }
    
    return versionsAvailable;
}

@end
