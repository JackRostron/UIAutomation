//
//  AvailableTargetsManager.h
//  USBTest
//
//  Created by Jack Rostron on 02/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IATAvailableTargetsManager : NSObject

+ (id)sharedManager;

- (NSArray *)physicalDevices;
- (NSArray *)simulators;

- (NSMenu *)availableTargetMenu;

@end
