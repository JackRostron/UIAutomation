//
//  JGRiOSDeviceMonitor.m
//  USBTest
//
//  Created by Jack Rostron on 02/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "JGRiOSDeviceMonitor.h"

@interface JGRUSBDeviceMonitor () //Expose private methods and variables, not best practice but works for this use case
@property (nonatomic, copy) void (^connected)(NSDictionary *device);
@property (nonatomic, copy) void (^removed)(NSDictionary *device);
- (NSDictionary *)usbDeviceInformation:(io_object_t)usb;
@end

@interface JGRiOSDeviceMonitor ()
@property (nonatomic, strong) NSArray *iOSDevices;
@end

@implementation JGRiOSDeviceMonitor

- (id)init
{
    if (self = [super init]) {
        self.iOSDevices = @[@"iPod", @"iPad", @"iPhone"];
    }
    return self;
}

- (void)usbDeviceAdded:(io_iterator_t)devices
{
    io_object_t currentUSBDevice;
    while ((currentUSBDevice = IOIteratorNext(devices))) {
        NSDictionary *usbDictionary = [self usbDeviceInformation:currentUSBDevice];
        if ([self isAnAppleDevice:usbDictionary]) {
            self.connected(usbDictionary);
        }
        IOObjectRelease(currentUSBDevice);
    }
}

- (void)usbDeviceRemoved:(io_iterator_t)devices
{
    io_object_t currentUSBDevice;
    while ((currentUSBDevice = IOIteratorNext(devices))) {
        NSDictionary *usbDictionary = [self usbDeviceInformation:currentUSBDevice];
        if ([self isAnAppleDevice:usbDictionary]) {
            self.removed(usbDictionary);
        }
        IOObjectRelease(currentUSBDevice);
    }
}

- (BOOL)isAnAppleDevice:(NSDictionary *)device
{
    return [self.iOSDevices containsObject:[device objectForKey:@"name"]];
}

@end
