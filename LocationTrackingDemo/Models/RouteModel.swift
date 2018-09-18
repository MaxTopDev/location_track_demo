//
//  RouteSegment.swift
//  LocationTrackingDemo
//
//  Created by Ohrimenko Maxim on 9/14/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

/**
 Location representation model
 */
class Location: Object {
    @objc dynamic var eventType: Int = 0
    @objc dynamic var eventTimestamp: Int = 0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
}
/**
 Route object representation model
 */
class RouteObject: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var origin: Location?
    @objc dynamic var destination: Location?
    @objc dynamic var startInterval: TimeInterval = 0.0
    @objc dynamic var endInterval: TimeInterval = 0.0
}
