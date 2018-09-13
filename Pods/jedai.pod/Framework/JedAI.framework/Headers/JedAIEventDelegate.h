//
//  JedAIEventListener.h
//  JedAI
//
//  Created by Michael Paschenko on 5/8/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "JedAIEvent.h"

/** `JedAIEventDelegate` is an objective-c protocol which should be implemented by all the event listeners
 */
@protocol JedAIEventDelegate<NSObject>

/** Whould be called by the sdk once event satisfied by conditions will be reported.
 @param event generated event
 */
- (void)onEvent:(JedAIEvent* _Nonnull)event;

@end
