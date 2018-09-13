//
//  ViewController.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationTracker = LocationTracker()
    let jediWrapper = JediWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTracker.askForLocationPermission { [unowned self] (determined, allowed) in
            if allowed == true {
                self.jediWrapper.start()
            }
        }
    }
    
}

