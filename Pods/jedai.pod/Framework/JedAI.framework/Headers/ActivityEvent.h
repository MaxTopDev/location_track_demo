//
//  ActivityEvent.h
//  JedAI
//
//  Created by Michael Paschenko on 8/1/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "JedAIEvent.h"

/**
 * Activity types
 */
typedef NS_ENUM(NSUInteger, ActivityType) {
    UNKNOWN = 1,
    STILL = 1 << 1 ,
    IN_RIDE = 1 << 2 ,
    CYCLING = 1 << 3 ,
    WALKING = 1 << 4 ,
    RUNNING = 1 << 5 ,
    ASLEEP = 1 << 6
};

/**
* Inherits from {@link JedAIEvent}, and represents the activity events.
*/
@interface ActivityEvent : JedAIEvent

- (instancetype)initWithTimestamp:(long)eventTimestamp location:(CLLocationCoordinate2D)location isStart:(bool)isStart activity:(int)activity withConfidence:(int) confidence withTimeZone:(int) timeZone;

/**
*
* @return {@code true} if the activity is started. {@code false} when the activity ended
*/
@property (nonatomic, readonly) bool isStart;

/**
 *
 * @return the type of activity recognised
 */
@property (nonatomic, readonly) int  activity;

/**
 *
 * @return the confidence of activity recognised
 */
@property (nonatomic, readonly) int  confidence;



@end
