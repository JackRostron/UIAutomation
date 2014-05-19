//
//  IATSimulatorDevice.h
//  UIAutomation
//
//  Created by Jack Rostron on 19/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSimulatorSize3inch,
    kSimulatorSize4inch,
    kSimulatorSizeiPad,
} kSimulatorSize;

typedef enum {
    kSimulatorProcessorBitRate32,
    kSimulatorProcessorBitRate64
} kSimulatorProcessorBitRate;

typedef enum {
    kiOSSimulatoriPhone,
    kiOSSimulatoriPad
} kiOSSimulator;


@interface IATSimulatorDevice : NSObject

@property (nonatomic, strong) NSString *rawVersion;

- (id)initWithVersion:(NSString *)version;

- (NSString *)getCommandLineVersionWithSimulatorDevice:(kiOSSimulator)device andSize:(kSimulatorSize)size andBitRate:(kSimulatorProcessorBitRate)bitRate;
- (NSString *)getCleanLocationWithBitRate:(kSimulatorProcessorBitRate)bitRate;

@end
