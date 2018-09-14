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

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
    
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

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
    }
    
}

