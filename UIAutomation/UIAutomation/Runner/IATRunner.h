//
//  IATRunner.h
//  UIAutomation
//
//  Created by Jack Rostron on 15/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IATApp.h"

@interface IATRunner : NSObject

+ (id)sharedRunner;

- (void)testWeCanTalkToInstruments;

- (void)runTestForApp:(IATApp *)app;

@end
