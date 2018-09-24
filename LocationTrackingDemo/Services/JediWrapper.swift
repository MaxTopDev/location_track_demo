//
//  JediWrapper.swift
//  LocationTrackingDemo
//
//  Created by Ohrimenko Maxim on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import Foundation
import JedAI
import RealmSwift

/**
 Wrapper protocol to notify about finished route event
 */
protocol JediWrapperDelegate: class {
    /**
     Notify about finished route event
     */
    func onEventFinished()
}

/**
 Class to act as convenient wrapper for JedAI sdk
 */
class JediWrapper: NSObject {
    
    /**
     Realm instance
     */
    private var realm: Realm!
    /**
     Wrapper delegate
     */
    weak var delegate: JediWrapperDelegate?
    
    /**
     JedAI instance
     */
    private lazy var jedAi: JedAI = { [unowned self] in
        let shared = JedAI.sharedInstance()!
        shared.setup()
        
        // setup configuration for JedAiSDK
        let builder = EventConfigBuilder()
        builder.onEventTypes(VISIT_TYPE.ACTIVITY_START_EVENT_TYPE.rawValue | VISIT_TYPE.ACTIVITY_END_EVENT_TYPE.rawValue)
        shared.setActivityRecognitionEnabled(true)
        shared.registerEvents(self, eventConfig: builder.build())
        return shared
    }()
    
    /**
     Initialisation method
     */
    init(realm: Realm) {
        super.init()
        self.realm = realm
    }
    /**
     Unregister JedAISdk from events
     */
    func unregister() {
        JedAI.sharedInstance().unregisterEvents(self)
    }
    /**
     Start JedAI SDK
     */
    func start() {
        jedAi.start()
    }
    /**
     Stop JedAI SDK
     */
    func stop() {
        jedAi.start()
    }
    /**
     Simulate JedAI SDK
     */
    func simulate(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let builder = SimulatedVisitBuilder()
        
        builder.setCoordinate(origin)
        builder.setAccuracy(1)
        builder.setVisitStart(Date())
        DevTools.simulateEvent(builder)
        
        builder.setCoordinate(destination)
        builder.setAccuracy(1)
        builder.setVisitStart(Date(timeIntervalSinceNow: Date().timeIntervalSinceNow - 3600))
        builder.setVisitEnd(Date())
        DevTools.simulateEvent(builder)
    }
    
}

/**
 JedAIEventDelegate implementation
 */
extension JediWrapper: JedAIEventDelegate {
    
    /**
     Invoked when a new event is detected from SDK
     */
    func onEvent(_ event: JedAIEvent) {
        
        // check if the activity is type of ride event
        if let rideEvent = event as? ActivityInRideEvent {
            
            // create internal location struct
            let location = Location()
            location.latitude = event.location.latitude
            location.longitude = event.location.longitude
            location.eventTimestamp = event.eventTimestamp
            location.eventType = event.eventType
            
            // check if event is started
            if rideEvent.isStart {
                // finish all previous routes by setting the current start date and location
                DispatchQueue.main.async {
                    let routeObjects = RouteObject.all(in: self.realm).filter("endInterval == %@", 0.0)
                    routeObjects.forEach { (route) in
                        try! self.realm.write {
                            route.destination = location
                            route.endInterval = Date().timeIntervalSince1970
                        }
                    }
                }
                
                // create new route with origin location and save to internal database
                let routeObject = RouteObject()
                routeObject.origin = location
                routeObject.startInterval = Date().timeIntervalSince1970
                DispatchQueue.main.async {
                    try! self.realm.write {
                        self.realm.add(routeObject)
                    }
                }
                
            } else {
                
                // find the latest route (unfinished) and set the destination to finish it
                DispatchQueue.main.async {
                    let routeObjects = RouteObject.all(in: self.realm).filter("endInterval == %@", 0.0)
                    if let route = routeObjects.first {
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
    /**
     Update all routes with unfinished event with the latest location
     */
    func updateRoutesWithLatestDestination() {
        if let lastLocation = jedAi.getLastLocation() {
            let location = Location()
            location.latitude = lastLocation.coordinate.latitude
            location.longitude = lastLocation.coordinate.longitude
            DispatchQueue.main.async {
                let routeObjects = RouteObject.all(in: self.realm).filter("endInterval == %@", 0.0)
                routeObjects.forEach { (route) in
                    try! self.realm.write {
                        route.destination = location
                        route.endInterval = lastLocation.timestamp.timeIntervalSince1970
                    }
                }
            }
        }
    }
    
}

/**
 DB helper methods
 */
extension JediWrapper {
    
    /**
     Fetch locations from DB JedAISDK from date to date
     */
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
