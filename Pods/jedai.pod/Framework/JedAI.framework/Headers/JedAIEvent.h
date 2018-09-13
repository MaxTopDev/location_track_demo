//
//  JedAIEvent.h
//  JedAI
//
//  Created by Michael Paschenko on 5/9/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, VISIT_TYPE) {
    /**
     * User started a visit.
     */
    VISIT_START_EVENT_TYPE = 1 << 0,
    /**
     * User ended a visit. 
     */
    VISIT_END_EVENT_TYPE = 1 << 1,
    /**
     * User entered geofence
     */
    GEOFENCE_ENTER_EVENT_TYPE = 1 << 2,
    /**
     * User left geofence
     */
    GEOFENCE_EXIT_EVENT_TYPE = 1 << 3,
   
    ACTIVITY_START_EVENT_TYPE = 1 << 4,
    
    ACTIVITY_END_EVENT_TYPE = 1 << 5,
    
    ACTIVITY_CONFIDENCE_CHANGE_EVENT_TYPE = 1 << 6
};

/** `JedAIEvent` base class for all the reported events
 */
@interface JedAIEvent : NSObject

/** Init method
 */
- (id)initWithTimestamp:(long)eventTimestamp location:(CLLocationCoordinate2D)location eventType:(NSInteger)eventType withTimeZone:(int) timeZone;

/** Timestamp of the event
 */
@property (nonatomic, assign, readonly) long eventTimestamp;

/** Location of the event
 */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D location;

/** Type of the event
 */
@property (nonatomic, assign, readonly) NSInteger eventType;

/** Time zone of the event
 */
@property (nonatomic, assign, readonly) int timeZone;

@end
