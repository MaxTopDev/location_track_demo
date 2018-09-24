//
//  ViewController.swift
//  LocationTrackingDemo
//
//  Created by Ohrimenko Maxim on 9/13/18.
//  Copyright © 2018 Unicsoft. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

/**
 Class for custom annotation implementation
 */
class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
}

/**
 Class to manage Map view
 */
class MapViewController: UIViewController {

    /**
     MKMapView outlet
     */
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    }
    /**
     Realm instance
     */
    let realm = try! Realm()
    /**
     Location tracker instance
     */
    let locationTracker = LocationTracker()
    /**
     JedAi wrapper instance
     */
    var jediWrapper: JediWrapper!
    /**
     Stores the array of routes
     */
    var routes: Results<RouteObject>!
    
    /**
     Called after the controller's view is loaded into memory
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup the instances
        jediWrapper = JediWrapper(realm: realm)
        jediWrapper.delegate = self
        routes = RouteObject.all(in: realm)
        // ask for lcoation permission
        locationTracker.askForLocationPermission { [unowned self] (determined, allowed) in
            if allowed == true {
                self.jediWrapper.start()
                // show current user location on map
                self.locationTracker.getUserLocation(completion: { [unowned self] (location, error) in
                    guard let loc = location else { return }
                    let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self.mapView.setRegion(region, animated: true)
                })
            }
        }
        // show the latest route from DB on map
        if let route = routes.last {
            show(route: route)
        }
        // Subscribe for application termination
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    /**
     Deinitialisation
     */
    deinit {
        jediWrapper.stop()
        jediWrapper.unregister()
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Helper method to constuct route on map based on locations array
     */
    func constructRoute(locations: [CLLocation]) {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        DispatchQueue.main.async {
            let coordinates = locations.map({$0.coordinate})
            let myPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.add(myPolyline)
            
            if let firstLoc = locations.first, let lastLoc = locations.last {
                let annotationStart = CustomAnnotation()
                annotationStart.coordinate = CLLocationCoordinate2DMake(firstLoc.coordinate.latitude, firstLoc.coordinate.longitude)
                let annotationEnd = CustomAnnotation()
                annotationEnd.coordinate = CLLocationCoordinate2DMake(lastLoc.coordinate.latitude, lastLoc.coordinate.longitude)
                self.mapView.showAnnotations([annotationStart, annotationEnd], animated: true)
            }
        }
    }
    /**
     Method to invoke when application is terminated
     */
    @objc func applicationWillTerminate() {
        jediWrapper.updateRoutesWithLatestDestination()
    }
    
}

/**
 Helper methods
 */
extension MapViewController {
    
    /**
     Notifies the view controller that a segue is about to be performed
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListController" {
            let controller = segue.destination as! ListViewController
            controller.delegate = self
            controller.routes = self.routes
        }
    }
    
}

/**
 MKMapViewDelegate implementation
 */
extension MapViewController: MKMapViewDelegate {

    /**
     Asks the delegate for a renderer object to use when drawing the specified overlay
     */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.red
            return lineView
        }
        return MKOverlayRenderer()
    }
    
}

/**
 JediWrapperDelegate implementation
 */
extension MapViewController: JediWrapperDelegate {
    
    /**
     Notifies delegate that event is finished from JedAI sdk
     */
    func onEventFinished() {
        if let latestRoute = routes.last {
            show(route: latestRoute)
        }
    }
    
}

/**
 ListViewControllerDelegate implementation
 */
extension MapViewController: ListViewControllerDelegate {
    
    /**
     Notifies delegate to show the route on map
     */
    func show(route: RouteObject) {
        let fromDate = Date(timeIntervalSince1970: route.startInterval)
        let toDate = route.endInterval == 0.0 ? Date() : Date(timeIntervalSince1970: route.endInterval)
        if let locations = jediWrapper.fetchLocations(from: fromDate, to: toDate) {
            constructRoute(locations: locations)
        }
    }
    /**
     Notifies delegate to clear all on map
     */
    func clearAll() {
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
}

