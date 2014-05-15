//
//  IATApp.m
//  UIAutomation
//
//  Created by Jack Rostron on 15/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import "IATApp.h"

@implementation IATApp

- (id)initWithName:(NSString *)name andBundleID:(NSString *)bundleID atLocation:(NSString *)projectLocation
{
    if (self = [super init]) {
        self.name = name;
        self.bundleID = bundleID;
        self.projectLocation = projectLocation;
    }
    return self;
}

@end
