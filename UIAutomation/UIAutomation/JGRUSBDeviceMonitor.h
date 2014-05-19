//
//  JGRUSBDeviceMonitor.h
//  RunScriptTest
//
//  Created by Jack Rostron on 02/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JGRUSBDeviceMonitor : NSObject

- (void)monitorForUSBDevicesWithConnectedBlock:(void(^)(NSDictionary *device))connected
                                  removedBlock:(void(^)(NSDictionary *device))removed;

@end
