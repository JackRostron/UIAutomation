//
//  IATSimulatorDevice.m
//  UIAutomation
//
//  Created by Jack Rostron on 19/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATSimulatorDevice.h"

@implementation IATSimulatorDevice

- (id)initWithVersion:(NSString *)version
{
    if (self = [super init]) {
        self.rawVersion = version;
    }
    return self;
}

- (NSString *)getCommandLineVersionWithSimulatorDevice:(kiOSSimulator)device andSize:(kSimulatorSize)size andBitRate:(kSimulatorProcessorBitRate)bitRate
{
    if (device == kiOSSimulatoriPhone && size == kSimulatorSize3inch && bitRate == kSimulatorProcessorBitRate32) {
        return [NSString stringWithFormat:@"iPhone Retina (3.5-inch) - Simulator - iOS %@", self.rawVersion];
        
    } else if (device == kiOSSimulatoriPhone && size == kSimulatorSize3inch && bitRate == kSimulatorProcessorBitRate64) {
        return [NSString stringWithFormat:@"iPhone Retina (3.5-inch 64-bit) - Simulator - iOS %@", self.rawVersion];
        
    } else if (device == kiOSSimulatoriPhone && size == kSimulatorSize4inch && bitRate == kSimulatorProcessorBitRate32) {
        return [NSString stringWithFormat:@"iPhone Retina (4-inch) - Simulator - iOS %@", self.rawVersion];
        
    } else if (device == kiOSSimulatoriPhone && size == kSimulatorSize4inch && bitRate == kSimulatorProcessorBitRate64) {
        return [NSString stringWithFormat:@"iPhone Retina (4-inch 64-bit) - Simulator - iOS %@", self.rawVersion];
        
    } else if (device == kiOSSimulatoriPad && size == kSimulatorSizeiPad && bitRate == kSimulatorProcessorBitRate32) {
        return [NSString stringWithFormat:@"iPad Retina - Simulator - iOS %@", self.rawVersion];
        
    } else if (device == kiOSSimulatoriPad && size == kSimulatorSizeiPad && bitRate == kSimulatorProcessorBitRate64) {
        return [NSString stringWithFormat:@"iPad Retina (64-bit) - Simulator - iOS %@", self.rawVersion];
        
    }
    return nil;
}

- (NSString *)getCleanLocationWithBitRate:(kSimulatorProcessorBitRate)bitRate
{
    if (bitRate == kSimulatorProcessorBitRate32) {
        return [NSString stringWithFormat:@"~/Library/Application\\ Support/iPhone\\ Simulator/%@/Applications/", self.rawVersion];
        
    } else if (bitRate == kSimulatorProcessorBitRate64) {
        return [NSString stringWithFormat:@"~/Library/Application\\ Support/iPhone\\ Simulator/%@-64/Applications/", self.rawVersion];
    }
    return nil;
}

@end
