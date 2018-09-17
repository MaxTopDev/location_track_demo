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
    func onEvent(_ event: RouteObject)
}

class JediWrapper: NSObject {
    
    private let realm = try! Realm()
    
    private lazy var jedAi: JedAI = { [unowned self] in
        let shared = JedAI.sharedInstance()
        let config = ConfigJedAi.createDefaultConfig()
        shared?.registerEvents(self, eventConfig: config!.build())
        return shared!
    }()
    
    weak var delegate: JediWrapperDelegate?
    
    class func setup() {
        JedAI.sharedInstance().setup()
        DevTools.setLogLevel(LOG_LEVEL.VERBOSE)
    }
    
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
        
        delegate?.onEvent(routeObject)
    }
}

extension JediWrapper: JedAIEventDelegate {
    
    func onEvent(_ event: JedAIEvent) {
        
        let location = Location()
        location.latitude = event.location.latitude
        location.longitude = event.location.longitude
        location.eventTimestamp = event.eventTimestamp
        location.eventType = event.eventType
        
        let routeObject = RouteObject()
        routeObject.origin = location
        routeObject.destination = location
        
        DispatchQueue.main.async {
            try! self.realm.write { self.realm.add(routeObject) }
        }
        
        delegate?.onEvent(routeObject)
    }
    
}
