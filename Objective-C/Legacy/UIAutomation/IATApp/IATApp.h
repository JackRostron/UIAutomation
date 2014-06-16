//
//  IATApp.h
//  UIAutomation
//
//  Created by Jack Rostron on 15/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IATApp : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *bundleID;
@property (nonatomic, strong) NSString *projectLocation;

- (id)initWithName:(NSString *)name andBundleID:(NSString *)bundleID atLocation:(NSString *)projectLocation;

@end
