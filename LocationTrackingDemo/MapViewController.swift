//
//  ViewController.swift
//  LocationTrackingDemo
//
//  Created by developer MacBook on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
}

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    let realm = try! Realm()
    let locationTracker = LocationTracker()
    let jediWrapper = JediWrapper()
    var routes: Results<RouteObject>!
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jediWrapper.delegate = self
        routes = realm.objects(RouteObject.self)
        locationTracker.askForLocationPermission { [unowned self] (determined, allowed) in
            if allowed == true {
                self.jediWrapper.start()
                self.locationTracker.getUserLocation(completion: { (location, error) in
                    if self.previousLocation == nil {
                        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                        self.mapView.setRegion(region, animated: true)
                        
                        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
                        myAnnotation.coordinate = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude);
                        myAnnotation.title = "Current location"
                        self.mapView.addAnnotation(myAnnotation)
                    } else {
//                        self.jediWrapper.onEventFake(cllocation: location!)
                    }
                    self.previousLocation = location
                    
//                    self.jediWrapper.simulate(origin: self.previousLocation!.coordinate, destination: location!.coordinate)
                })
            }
        }
    }
    
    deinit {
        jediWrapper.stop()
        jediWrapper.unregister()
    }
    
    func updateRoute() {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        DispatchQueue.main.async {
            let routeArray = Array(self.routes)
            let annotations = routeArray.map { (routeObject) -> MKAnnotation in
                let annotation = CustomAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(routeObject.destination!.latitude, routeObject.destination!.longitude)
                return annotation
            }
            self.mapView.addAnnotations(annotations)
            
            let coordinates = annotations.map({$0.coordinate})
            let myPolyline = MKPolyline.init(coordinates: coordinates, count: coordinates.count)
            self.mapView.add(myPolyline)
        }
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.red
            return lineView
        }
        return MKOverlayRenderer()
    }
    
}

extension MapViewController: JediWrapperDelegate {
    
    func onEvent(_ event: RouteObject) {
        updateRoute()
    }
    
}

