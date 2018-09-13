//
//  DevTools.h
//  JedAI
//
//  Created by Michael Paschenko on 5/23/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JILogLevel.h"
#import "SimulatedVisitBuilder.h"

/**
 `DevTools` is the main class of the sdk in charge of help developers to better understand the SDK
 */
@interface DevTools : NSObject
/// Set log level for the SDK
+ (void)setLogLevel:(LOG_LEVEL)logLevel;
/// Simulate event with builder provided
+ (void)simulateEvent:(SimulatedVisitBuilder* _Nonnull)builder;
/// Clear local visits database
+ (void)clearVisitsDatabase;
///
+ (void)reloadConfig;

+ (NSArray*)getConfigStats;

@end
