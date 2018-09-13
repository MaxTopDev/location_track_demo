//
//  EventConfig.h
//  JedAI
//
//  Created by Michael Paschenko on 5/9/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventConfig;
@class JIVisitEvent;

/** `EventConfigBuilder` is an objective-c class responsible for creating EventConfig for events
    The developer should have the option to listen to specific events, based on the following parameters:
    Which Event - Enter / Exit / or Both
    POI Type - Optional. Filter only specific types to be notified on
    POI Name - Optional. Filter only specific names to be notified on
 */
@interface EventConfigBuilder : NSObject

/**
 * The listener will be called only when the event is one of the following types.
 * You have to specify at least one event (Mandatory)
 *
 * @param eventTypes a mask of types. Check JedAIEvent for the available types
 * @return self
 */
- (EventConfigBuilder*)onEventTypes:(NSUInteger)eventTypes;

/**
 * The listener will be called only when the poi has
 * one of the provided types
 *
 * @param poiTypes array of the POI types to listen
 * @return self
 */
- (EventConfigBuilder*)hasPoiTypes:(NSArray*)poiTypes;

- (EventConfigBuilder*)hasActivityType:(long)activityType;

- (EventConfigBuilder*)hasMinimalActivityConfidence:(int)confidence;

- (EventConfigBuilder*)hasTransportType:(long)transportType;

/**
 * The listener will be called only when the poi Poi has
 * one of the provided names
 *
 * @param poiNames array of the POI names to listen
 * @return self
 */
- (EventConfigBuilder*)hasPoiNames:(NSArray* _Nullable)poiNames;

/**
 * Build the config for a lister
 * @return the config
 *
 * @throws NSException when the builder has wrong arguments
 */
-(EventConfig*)build;

@end

/** `EventConfig` is an objective-c class responsible for filtering events
 */
@interface EventConfig : NSObject

/** Init method
 */
- (id)initWithBuilder:(EventConfigBuilder*)builder;

/** Accepted event types
 */
- (NSUInteger)getEventTypes;

/** Array of the accepted POI types
 */
- (NSArray*)getPoiTypes;

/** Array of the accepter POI names
 */
- (NSArray*)getPoiNames;

/**
    bit array of Activity Types
 */
- (long)getActivityTypes;

- (int)getMinimalActivityConfidence;

- (long)getTransportType;

@end

