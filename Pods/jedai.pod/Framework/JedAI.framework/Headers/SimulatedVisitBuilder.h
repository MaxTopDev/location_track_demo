//
//  SimulatedVisitBuilder.h
//  JedAI
//
//  Created by Michael Paschenko on 6/5/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 `SimulatedVisitBuilder` is the main class which allow a developer to make fake visit to force so that JedAI SDK will trigger this fake event and the host application will get it
 */
@interface SimulatedVisitBuilder : NSObject
/// Set coordinates for the fake visit
-(SimulatedVisitBuilder*) setCoordinate:(CLLocationCoordinate2D)coordinate;
/// Set accuracy for fake visit
-(SimulatedVisitBuilder*) setAccuracy:(float)accuracy;
/// Set visit start time
-(SimulatedVisitBuilder*) setVisitStart:(NSDate* _Nullable)date;
/// Set visit end time
-(SimulatedVisitBuilder*) setVisitEnd:(NSDate* _Nullable)date;
/// Builds a visit
-(CLVisit*)build;
@end
