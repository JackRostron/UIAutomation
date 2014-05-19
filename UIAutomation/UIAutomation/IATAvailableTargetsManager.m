//
//  AvailableTargetsManager.m
//  USBTest
//
//  Created by Jack Rostron on 02/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATAvailableTargetsManager.h"
#import "JGRiOSDeviceMonitor.h"
#import "NSString+CommandLineScript.h"

@interface IATAvailableTargetsManager ()
@property (nonatomic, strong) NSMutableArray *attachedDevices;
@property (nonatomic, strong) NSMutableArray *availableSimulators;

@property (nonatomic, strong) NSDate *lastCheckForSimulators;
@end

@implementation IATAvailableTargetsManager

#pragma mark - Initialisation
+ (id)sharedManager
{
    static IATAvailableTargetsManager *sharedDeviceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDeviceManager = [[self alloc] init];
    });
    return sharedDeviceManager;
}

- (id)init
{
    if (self = [super init]) {
        self.attachedDevices = [[NSMutableArray alloc] init];
        self.availableSimulators = [[NSMutableArray alloc] init];
        
        [self getPhysicalDevices];
        [self getSimulatorVersions];
    }
    return self;
}

#pragma mark - Public methods
- (NSArray *)simulators
{
    if ([self.lastCheckForSimulators timeIntervalSinceNow] > 60 || !self.lastCheckForSimulators) { //Less than a minute since last check
        self.lastCheckForSimulators = [NSDate date];
        [self getSimulatorVersions];
    }
    return self.availableSimulators;
}

- (NSArray *)physicalDevices
{
    return self.attachedDevices;
}

- (NSMenu *)availableTargetMenu
{
    //NSLog(@"%@", [self getFormattedSimulatorList]);
    
    NSArray *simulators = [self getFormattedSimulatorList];
    
    
    
    
    return nil;
}


#pragma mark - Private methods
- (void)getPhysicalDevices
{
    JGRiOSDeviceMonitor *iOSDeviceMonitor = [[JGRiOSDeviceMonitor alloc] init];
    [iOSDeviceMonitor monitorForUSBDevicesWithConnectedBlock:^(NSDictionary *device) {
        [self.attachedDevices addObject:device];
    } removedBlock:^(NSDictionary *device) {
        [self.attachedDevices removeObject:device];
    }];
}

- (void)getSimulatorVersions
{
    if ([self.lastCheckForSimulators timeIntervalSinceNow] > 60 || !self.lastCheckForSimulators) { //Less than a minute since last check
        self.lastCheckForSimulators = [NSDate date];
        
        [self.availableSimulators removeAllObjects];
        
        //NSString *availableSimulators = @"xcodebuild -showsdks";
        NSString *availableSimulators = @"instruments -w printSimulators";
        NSString *unparsedSimulators = [availableSimulators commandLineOutput];
        NSArray *sdkLines = [unparsedSimulators componentsSeparatedByString:@"\n"];
        
        for (NSString *line in sdkLines) {
            if ([line rangeOfString:@" - Simulator - "].location != NSNotFound) {
                [self.availableSimulators addObject:line];
            }
        }
        
    } else {
        NSLog(@"Not updating since last check within 60seconds");
    }
}

- (NSArray *)getFormattedSimulatorList
{
    if ([self.simulators count] == 0) {
        [self getSimulatorVersions];
    }
    
    NSMutableArray *simulatorArray = [[NSMutableArray alloc] initWithCapacity:[self.simulators count]];
    
    for (int x = 0; x < [self.simulators count]; x++) {
        NSString *line = [self.simulators objectAtIndex:x];
        NSArray *brokenLine = [line componentsSeparatedByString:@" - "];
        
        if (![simulatorArray containsObject:[brokenLine firstObject]]) {
            [simulatorArray addObject:[brokenLine firstObject]];
        }
    }
    
    NSMutableArray *finalArray = [[NSMutableArray alloc] initWithCapacity:[self.simulators count]];
    
    for (int x = 0; x < [simulatorArray count]; x++) {
        NSDictionary *simulatorSetup = @{@"device" : [simulatorArray objectAtIndex:x],
                                         @"versions" : [self getVersionsForSimulatorDeviceType:[simulatorArray objectAtIndex:x]]};
        
        [finalArray addObject:simulatorSetup];
    }
    
    return finalArray;
}

- (NSArray *)getVersionsForSimulatorDeviceType:(NSString *)deviceString
{
    NSMutableArray *versionsAvailable = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < [self.simulators count]; x++) {
        NSString *line = [self.simulators objectAtIndex:x];
        NSArray *brokenLine = [line componentsSeparatedByString:@" - "];
        
        if ([[brokenLine firstObject] isEqualToString:deviceString]) {
            [versionsAvailable addObject:[brokenLine lastObject]];
        }
    }
    
    return versionsAvailable;
}

@end
