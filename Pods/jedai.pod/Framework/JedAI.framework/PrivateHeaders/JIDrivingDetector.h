//
//  IDrivingDetection.h
//  JedAI
//
//  Created by Michael Paschenko on 7/16/18.
//  Copyright © 2018 ANAGOG ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "JIDrivingDetectorDelegate.h"
#import "ActivityInRideEvent.h"

@interface JIDrivingDetector : NSObject

@property (nonatomic, readonly, getter=isDriving) bool driving;

- (IN_RIDE_CONFIDENCE)getInRideConfidence;

- (id)initWithDelegate:(id<JIDrivingDetectorDelegate>)delegate;
- (void)periodicJob:(CLLocation*)lastKnownLocation;

- (void)onCoreMotionDriving:(bool)driving confidence:(float)confidence;
- (void)onBluetoothConnected:(NSString*)deviceUID;
- (void)onBluetoothDisconnected:(NSString*)UID;
- (void)onStepsDetected:(int)currentSteps;
@end
