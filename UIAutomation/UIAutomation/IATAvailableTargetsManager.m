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
    [self getSimulatorVersions];
    return self.availableSimulators;
}

- (NSArray *)physicalDevices
{
    return self.attachedDevices;
}

- (NSMenu *)availableTargetMenu
{
    
    
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
    [self.availableSimulators removeAllObjects];
    
    NSString *availableSimulators = @"xcodebuild -showsdks";
    NSString *unparsedSimulators = [availableSimulators commandLineOutput];
    NSArray *sdkLines = [unparsedSimulators componentsSeparatedByString:@"\n"];
    
    for (NSString *line in sdkLines) {
        if ([line rangeOfString:@"iphonesimulator"].location != NSNotFound) {
            NSString *simulatorVersion = [line substringFromIndex:(line.length - 3)];
            [self.availableSimulators addObject:simulatorVersion];
        }
    }
}

@end
