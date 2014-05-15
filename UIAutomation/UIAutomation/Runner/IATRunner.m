//
//  IATRunner.m
//  UIAutomation
//
//  Created by Jack Rostron on 15/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATRunner.h"
#import "NSString+CommandLineScript.h"


#define traceTemplateLocation "/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"

@interface IATRunner ()
@end


@implementation IATRunner

+ (id)sharedRunner
{
    static IATRunner *sharedMyRunner = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyRunner = [[self alloc] init];
    });
    return sharedMyRunner;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)testWeCanTalkToInstruments
{
    
    //instruments -w '" + simulator_version + "' -t " + trace_template + " " + app_location_emulator + " -e UIASCRIPT " + test + " >> " + os.path.join(runner_dir, 'results/raw_results.txt
    
    //'iPhone Retina (4-inch) - Simulator - iOS 7.1'
    //"/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate"
    ///Users/JackRostron/Library/Developer/Xcode/DerivedData/PowaTag-beyjcveresnrxbcuyxgpplxujlnh/Build/Products/QA-iphonesimulator/PowaTag-Code-Coverage.app
    ///Users/JackRostron/Documents/Repos/powatag-ios-testing/runners/signUpRunner.js
    
    //instruments -w 'iPhone Retina (4-inch) - Simulator - iOS 7.1' -t '/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate' '/Users/JackRostron/Library/Developer/Xcode/DerivedData/PowaTag-beyjcveresnrxbcuyxgpplxujlnh/Build/Products/QA-iphonesimulator/PowaTag-Code-Coverage.app' -e UIASCRIPT '/Users/JackRostron/Documents/Repos/powatag-ios-testing/runners/signUpRunner.js'
    
    
    NSString *testString = @"instruments -w 'iPhone Retina (4-inch) - Simulator - iOS 7.1' -t '/Applications/Xcode.app/Contents/Applications/Instruments.app/Contents/PlugIns/AutomationInstrument.bundle/Contents/Resources/Automation.tracetemplate' '/Users/JackRostron/Library/Developer/Xcode/DerivedData/PowaTag-beyjcveresnrxbcuyxgpplxujlnh/Build/Products/QA-iphonesimulator/PowaTag-Code-Coverage.app' -e UIASCRIPT '/Users/JackRostron/Documents/Repos/powatag-ios-testing/runners/signUpRunner.js'";
    
    NSLog(@"%@", [testString commandLineOutput]);
}

- (void)cleanSimulator
{
    
}

- (void)runTestForApp:(IATApp *)app
{
    NSString *compiledString = [NSString stringWithFormat:@"instruments -w 'iPhone Retina (4-inch) - Simulator - iOS 7.1' -t '%s' '%@' -e UIASCRIPT '/Users/JackRostron/Documents/Repos/powatag-ios-testing/runners/signUpRunner.js'", traceTemplateLocation, app.projectLocation];
    
    NSLog(@"%@", [compiledString commandLineOutput]);
}

@end



















