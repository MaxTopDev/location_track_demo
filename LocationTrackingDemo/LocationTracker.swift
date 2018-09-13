//
//  LocationTracker.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import Foundation
import CoreLocation

typealias LocationCompletion = (_ location: CLLocation?, _ error: Error?) -> Void
typealias LocationPermissionCompletion = (_ determined: Bool, _ allowed: Bool) -> Void

class LocationTracker: NSObject {
    
    /**
     Location manager
     */
    private lazy var locationManager: CLLocationManager = { [unowned self] in
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
        }()
    /**
     Internal location completion block
     */
    private var completion: LocationCompletion?
    /**
     Internal permission completion block
     */
    private var permissionCompletion: LocationPermissionCompletion?
    
    override init() {
        super.init()
    }
    
    /**
     Prompts user to allow location permission. If user has agreed in first dialog then system dialog will appear to get permission
     - Parameters:
         - completion: completion block of registration process
     */
    func askForLocationPermission(completion: @escaping LocationPermissionCompletion) {
        if permissionStatus() == .notDetermined {
            requestLocationPermission(completion: completion)
        }
        else {
            completion(true, isPermissionAllowed())
        }
    }
    
    /**
     Returns fresh location in completion block. If it's first time call then it will enable location updates. Must be called only if permission is allowed
     - Parameters:
         - completion: completion block of get location process
     */
    func getUserLocation(withCompletion completion: @escaping LocationCompletion) {
        self.completion = completion
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Helpers
    
    /**
     Delegate method notifies about the authorisation status in location manager
     - Returns: CLLocationManager authorizationStatus
     */
    func permissionStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    /**
     Returns true if location permission status is determined
     */
    func isPermissionStatusDetermined() -> Bool {
        let status = permissionStatus()
        return status != .notDetermined
    }
    /**
     Returns true if location permission is allowed
     */
    func isPermissionAllowed() -> Bool {
        let status = permissionStatus()
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }
    /**
     Request permission to use location manager for the app
     - Parameters:
         - completion: completion block of permission process
     */
    func requestLocationPermission(completion: @escaping LocationPermissionCompletion) {
        permissionCompletion = completion
        locationManager.requestWhenInUseAuthorization()
    }
    
}

extension LocationTracker: CLLocationManagerDelegate {
    
    /**
     Delegate method notifies about the authorisation status in location manager
     - Parameters:
         - manager: CLLocationManager instance
         - status: CLAuthorizationStatus enum
     */
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //first time it's being called with notDetermined
        if status != .notDetermined {
            if let completion = permissionCompletion {
                completion(true, isPermissionAllowed())
            }
            permissionCompletion = nil
        }
    }
    /**
     Delegate method notifies about changes in current location (live)
     - Parameters:
         - manager: CLLocationManager instance
         - locations: list of locations
     */
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if let compl = completion {
                compl(location, nil)
            }
            completion = nil
        }
    }
    /**
     Delegate method notifies about errors in location manager
     - Parameters:
         - manager: CLLocationManager instance
         - error: error object
     */
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let compl = completion {
            compl(nil, error)
        }
        completion = nil
    }
    
}

