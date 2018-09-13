//
//  Poi.h
//  JedAI
//
//  Created by Michael Paschenko on 5/12/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, POLYGON_TYPE) {
    TYPE_PRIVATE = 0,
    TYPE_PUBLIC
};

/**
 * `Poi` a data class that represents the Point of Interest (Poi).
 * Poi can be anything - parking, mall, etc...
 */
@interface Poi : NSObject

/** unique id of the current Poi
 */
@property (nonatomic, assign, readonly) long poiId;

/** the name of the current poi
 */
@property (nonatomic, strong, readonly) NSString* _Nullable name;

/** the type of the current poi - Mall, Parking, etc...
 */
@property (nonatomic, strong, readonly) NSString* _Nullable type;

/** the center of the poi
 */
@property (nonatomic, assign, readonly) CLLocationCoordinate2D center;

/** the points of the polygon describing this poi
 */
@property (nonatomic, strong, readonly) NSArray<CLLocation*>* _Nullable polygon;

/** tags for this poi
 */
@property (nonatomic, strong, readonly) NSString* _Nullable tags;


@property (nonatomic, strong, readonly) NSString* _Nullable key;

/** Private or Public polygon
 */
@property (nonatomic, assign, readonly) POLYGON_TYPE polygonType;

/** Init method
 */
-(id)initWithId:(long)poiId name:(NSString* _Nullable)name type:(NSString* _Nullable)type center:(CLLocationCoordinate2D)center polygon:(NSArray<CLLocation*>* _Nullable)polygon tags:(NSString* _Nullable)tags polygonType:(int)polygonType;

/** get Dictionary with tags keys and values
 */
-(NSDictionary* _Nullable) getTagsParameters;
@end
