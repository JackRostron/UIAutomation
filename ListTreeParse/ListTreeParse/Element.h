//
//  Element.h
//  ListTreeParse
//
//  Created by Jack Rostron on 17/04/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Element : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, assign) CGRect frame;

@property (nonatomic, assign) NSInteger tabCount;

@property (nonatomic, strong) Element *parent;
@property (nonatomic, strong) NSArray *children;

+ (NSArray *)getElementsFromListTree:(NSString *)listTree;

@end
