//
//  IATJavascriptCommunicator.h
//  JavaScriptCommunicator
//
//  Created by Jack Rostron on 29/05/2014.
//  Copyright (c) 2014 Jack Rostron. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kInstrumentsCommandListTree,
} kInstrumentsCommand;

@interface IATJavascriptCommunicator : NSObject

+ (BOOL)sendCommandToInstruments:(kInstrumentsCommand)command throughDirectory:(NSString *)directory;

@end
