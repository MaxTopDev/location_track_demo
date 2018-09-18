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
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    }
    
    let realm = try! Realm()
    let locationTracker = LocationTracker()
    var jediWrapper: JediWrapper!
    var routes: Results<RouteObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jediWrapper = JediWrapper(realm: realm)
        jediWrapper.delegate = self
        routes = realm.objects(RouteObject.self)
        locationTracker.askForLocationPermission { [unowned self] (determined, allowed) in
            if allowed == true {
                self.jediWrapper.start()
                self.locationTracker.getUserLocation(completion: { [unowned self] (location, error) in
                    guard let loc = location else { return }
                    let center = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                    self.mapView.setRegion(region, animated: true)
                })
            }
        }
        
        if let route = routes.last {
            show(route: route)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    deinit {
        jediWrapper.stop()
        jediWrapper.unregister()
        NotificationCenter.default.removeObserver(self)
    }
    
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
    
    @objc func applicationWillTerminate() {
        jediWrapper.updateRoutesWithLatestDestination()
    }
    
}

extension MapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToListController" {
            let controller = segue.destination as! ListViewController
            controller.delegate = self
            controller.routes = self.routes
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
    
    func onEventFinished() {
        if let latestRoute = routes.last {
            show(route: latestRoute)
        }
    }
    
}

extension MapViewController: ListViewControllerDelegate {
    
    func show(route: RouteObject) {
        let fromDate = Date(timeIntervalSince1970: route.startInterval)
        let toDate = route.endInterval == 0.0 ? Date() : Date(timeIntervalSince1970: route.endInterval)
        if let locations = jediWrapper.fetchLocations(from: fromDate, to: toDate) {
            constructRoute(locations: locations)
        }
    }
    
    func clearAll() {
        self.mapView.removeOverlays(self.mapView.overlays)
    }
    
}

