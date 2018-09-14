//
//  JediWrapper.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import Foundation
import JedAI

class JediWrapper: NSObject {
    
    private lazy var jedAi: JedAI = { [unowned self] in
        let shared = JedAI.sharedInstance()
        let eventConfigBuilder = EventConfigBuilder()
        eventConfigBuilder.onEventTypes(VISIT_TYPE.ACTIVITY_START_EVENT_TYPE.rawValue | VISIT_TYPE.ACTIVITY_END_EVENT_TYPE.rawValue)
        eventConfigBuilder.hasPoiNames(["Airport", "Park"])
        shared?.registerEvents(self, eventConfig: eventConfigBuilder.build())
        return shared!
    }()
    
    class func setup() {
        JedAI.sharedInstance().setup()
    }
    
    func start() {
        jedAi.start()
    }
    
    func stop() {
        jedAi.start()
    }
}

extension JediWrapper: JedAIEventDelegate {
    
    func onEvent(_ event: JedAIEvent) {
        print(event)
    }
    
}
