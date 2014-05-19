//
//  JGRUSBDeviceMonitor.m
//  RunScriptTest
//
//  Created by Jack Rostron on 02/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "JGRUSBDeviceMonitor.h"

#include <IOKit/IOKitLib.h>
#include <IOKit/IOMessage.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/usb/IOUSBLib.h>

id referenceToSelf;

@interface JGRUSBDeviceMonitor ()
@property (nonatomic, copy) void (^connected)(NSDictionary *device);
@property (nonatomic, copy) void (^removed)(NSDictionary *device);
@end

@implementation JGRUSBDeviceMonitor

- (void)monitorForUSBDevicesWithConnectedBlock:(void(^)(NSDictionary *device))connected
                                  removedBlock:(void(^)(NSDictionary *device))removed
{
    self.connected = connected;
    self.removed = removed;
    
    [self setupUSBMonitoring];
}

#pragma mark - IOKit Callbacks
void usbDeviceAppeared(void *refCon, io_iterator_t iterator)
{
    [referenceToSelf usbDeviceAdded:iterator];
}

void usbDeviceDisappeared(void *refCon, io_iterator_t iterator)
{
    [referenceToSelf usbDeviceRemoved:iterator];
}

#pragma mark - IOKit Setup
- (void)setupUSBMonitoring
{
    referenceToSelf = self;
    
    io_iterator_t newDevicesIterator = 0;
    io_iterator_t lostDevicesIterator = 0;
    
    NSMutableDictionary *connectUSBDictionary = (__bridge NSMutableDictionary *)IOServiceMatching(kIOUSBDeviceClassName);
    NSMutableDictionary *disconnectUSBDictionary = (__bridge NSMutableDictionary *)IOServiceMatching(kIOUSBDeviceClassName);
    
    if (connectUSBDictionary == nil || disconnectUSBDictionary == nil){
        NSLog(@"Could not initialise USB dictionaries");
        return;
    }
    
    IONotificationPortRef notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
    CFRunLoopSourceRef notificationRunLoopSource = IONotificationPortGetRunLoopSource(notificationPort);
    CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], notificationRunLoopSource, kCFRunLoopDefaultMode);
    
    kern_return_t notificationSetup = IOServiceAddMatchingNotification(notificationPort,
                                                                       kIOMatchedNotification,
                                                                       (__bridge CFDictionaryRef)connectUSBDictionary,
                                                                       usbDeviceAppeared,
                                                                       (__bridge void *)self,
                                                                       &newDevicesIterator);
    
    if (notificationSetup) NSLog(@"Error initialising connection notification");
    
    notificationSetup = IOServiceAddMatchingNotification(notificationPort,
                                                         kIOTerminatedNotification,
                                                         (__bridge CFDictionaryRef)disconnectUSBDictionary,
                                                         usbDeviceDisappeared,
                                                         (__bridge void *)self,
                                                         &lostDevicesIterator);
    
    if (notificationSetup) NSLog(@"Error initialising remove notification");
    
    [self usbDeviceAdded:newDevicesIterator];
    [self usbDeviceRemoved:lostDevicesIterator];
}


#pragma mark ObjC Callback functions
- (void)usbDeviceAdded:(io_iterator_t)devices
{
    io_object_t currentUSBDevice;
    while ((currentUSBDevice = IOIteratorNext(devices))) {
        NSDictionary *usbDictionary = [self usbDeviceInformation:currentUSBDevice];
        if (usbDictionary) {
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
        if (usbDictionary) {
            self.removed(usbDictionary);
        }
        IOObjectRelease(currentUSBDevice);
    }
}

- (NSDictionary *)usbDeviceInformation:(io_object_t)usb
{
    CFMutableDictionaryRef	entryProperties = NULL;
    IORegistryEntryCreateCFProperties(usb, &entryProperties, NULL, 0);
    
    NSString *name = (NSString *) CFDictionaryGetValue(entryProperties, CFSTR(kUSBProductString));
    NSString *serial = (NSString *) CFDictionaryGetValue(entryProperties, CFSTR(kUSBSerialNumberString));
    
    if (name && serial) {
        return @{@"name" : name,
                 @"uuid" : serial};
    }
    
    return nil;
}

@end
