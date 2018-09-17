//
//  ConfigJedAi.m
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/14/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

#import "ConfigJedAi.h"

@implementation ConfigJedAi

+ (EventConfigBuilder *)createDefaultConfig {
    EventConfigBuilder *builder = [EventConfigBuilder new];
    [builder onEventTypes:ACTIVITY_START_EVENT_TYPE | ACTIVITY_END_EVENT_TYPE];
    return builder;
}

@end
