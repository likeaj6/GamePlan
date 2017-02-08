//
//  MapViewController.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol hasMap {
}

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var eventMarkers = [String:EventMarker]()
    var events: [Event]?
    var selectedEvent: Event?
    
    var currentLocation: CLLocation?
    var currentCoordinate: CLLocationCoordinate2D?
    
    let locationManager = CLLocationManager()
    
    var locationManagerOn = false
    var updatingLocation = false
    
    lazy var mapView:GMSMapView = {
        let map = GMSMapView(frame: self.view.bounds)
        map.delegate = self
        map.animate(toZoom: 18)
        map.isMyLocationEnabled = true
        map.settings.myLocationButton = true
        return map
    }()
    
    lazy var rightButton: UIButton = {
        let rb = UIButton(type: UIButtonType.detailDisclosure)
        rb.title(for: UIControlState())
        rb.setTitle("Swag", for: UIControlState())
        rb.addTarget(self, action: #selector(MapViewController.rightButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        return rb
    }()
    
    var camera:GMSCameraPosition? {
        didSet {
            _ = GMSCameraPosition.camera(withLatitude: 39.0000, longitude: -75.0000, zoom: 5)
        }
    }
    
    convenience init(frame:CGRect){
        self.init(nibName: nil, bundle: nil)
        self.view.frame = frame
        getInitialLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.selectMarker(_:)), name: NSNotification.Name(rawValue: "selectEvent"), object: nil)
        self.view.addSubview(self.mapView)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
        self.mapView.delegate = nil
    }
    func loadMarkersWithArray(_ someEvents:[Event]){
        mapView.clear()
        for i in 0 ..< someEvents.count {
            
            let marker:EventMarker = EventMarker()
            let e = someEvents[i] as Event
            print("\(e.coordinate)")
            marker.event = e
            marker.position = e.coordinate
            marker.title =  e.title
            marker.snippet = e.eventDescription
            eventMarkers[e.uid!] = marker
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.mapView
        }
    }
    func animateToCurrentCoordinate() {
        mapView.animate(toLocation: currentCoordinate!)
    }
    // select event from tableview
    func selectMarker(_ notification :NSNotification)  {
        self.selectedEvent = notification.object as? Event
        
        
        if let event = self.selectedEvent {
            mapView.animate(toLocation: event.coordinate)
            mapView.selectedMarker = eventMarkers[event.uid!]
            //let marker:GMSMarker = eventMarkers[self.selectedEvent!.id]!
        }
    }
    
    func rightButtonTapped(_ sender: UIButton!){
        if let event:Event = selectedEvent{
            print("event name:\(event.title)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "navigateToDetail"), object: event)
        } else {
            print("no event")
        }
    }
    
    func getInitialLocation() {
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
        } else {
            startLocationManager()
            print("starting Location Manager")
            //lastLocationError = nil
            //placemark = nil
            //lastGeocodingError = nil
        }
    }
    
    
    func startLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 25
        locationManager.startUpdatingLocation()
        locationManagerOn = true
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            locationManagerOn = false
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        return false
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message:
            "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    //locationManager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let camera = GMSCameraPosition.camera(withLatitude: 39.0000, longitude: -75.0000, zoom: 5)
        mapView.camera = camera
        let alert = UIAlertController(title: "Failed to Update Location",
                                      message:
            "Please try again later.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last! as CLLocation
        //print("didUpdateLocations \(newLocation)")
        if currentLocation == nil || currentLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            currentLocation = newLocation
            let newCoordinate = currentLocation!.coordinate
            currentCoordinate = newCoordinate
            mapView.animate(toLocation: newCoordinate)
            print("Animating to Current Location!")
        }
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
    }

}
