//
//  JediWrapper.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import Foundation
import JedAI
import RealmSwift

protocol JediWrapperDelegate: class {
    func onEventFinished()
}

class JediWrapper: NSObject {
    
    private var realm: Realm!
    
    private lazy var jedAi: JedAI = { [unowned self] in
        let shared = JedAI.sharedInstance()!
        shared.setup()
        
        let builder = EventConfigBuilder()
        builder.onEventTypes(VISIT_TYPE.ACTIVITY_START_EVENT_TYPE.rawValue | VISIT_TYPE.ACTIVITY_END_EVENT_TYPE.rawValue)
        shared.setActivityRecognitionEnabled(true)
        shared.registerEvents(self, eventConfig: builder.build())
        return shared
    }()
    
    init(realm: Realm) {
        super.init()
        self.realm = realm
    }
    
    weak var delegate: JediWrapperDelegate?
    
    func unregister() {
        JedAI.sharedInstance().unregisterEvents(self)
    }
    
    func start() {
        jedAi.start()
    }
    
    func stop() {
        jedAi.start()
    }
    
    func simulate(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let builder = SimulatedVisitBuilder()
        
        builder.setCoordinate(origin)
        builder.setAccuracy(1)
        builder.setVisitStart(Date())
        DevTools.simulateEvent(builder)
        
        builder.setCoordinate(destination)
        builder.setAccuracy(1)
        builder.setVisitStart(Date.init(timeIntervalSinceNow: Date().timeIntervalSinceNow - 3600))
        builder.setVisitEnd(Date())
        DevTools.simulateEvent(builder)
    }
    
    func onEventFake(cllocation: CLLocation) {
        let location = Location()
        location.latitude = cllocation.coordinate.latitude
        location.longitude = cllocation.coordinate.longitude
        
        let routeObject = RouteObject()
        routeObject.origin = location
        routeObject.destination = location
        
        DispatchQueue.main.async {
            try! self.realm.write { self.realm.add(routeObject) }
        }
        
        delegate?.onEventFinished()
    }
}

extension JediWrapper: JedAIEventDelegate {
    
    func onEvent(_ event: JedAIEvent) {
        
        if let rideEvent = event as? ActivityInRideEvent {
            
            let location = Location()
            location.latitude = event.location.latitude
            location.longitude = event.location.longitude
            location.eventTimestamp = event.eventTimestamp
            location.eventType = event.eventType
            
            if rideEvent.isStart {
                let routeObject = RouteObject()
                routeObject.origin = location
                routeObject.startInterval = Date().timeIntervalSince1970
                
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.add(routeObject)
                    }
                }
            } else {
                
                let routeObjects = self.realm.objects(RouteObject.self).filter("endInterval == %@", 0.0)
                
                if let route = routeObjects.first {
                    DispatchQueue.main.async {
                        try! self.realm.write {
                            route.destination = location
                            route.endInterval = Date().timeIntervalSince1970
                        }
                    }
                }
                delegate?.onEventFinished()
            }
        }
    }
    
}

// DB helper methods
extension JediWrapper {
    
    func fetchLocations(from fromDate: Date, to toDate: Date) -> [CLLocation]? {
        let predicate = NSPredicate(format: "timestamp >= %@ && timestamp <= %@", argumentArray: [fromDate, toDate])
        let sortDescriptor = NSSortDescriptor.init(key: "timestamp", ascending: false)
        let result = jedAi.getLocationHistory(by: predicate, sortDescriptors: [sortDescriptor])
        if let locations = result as? [CLLocation] {
            return locations
        } else {
            return nil
        }
    }
    
}
