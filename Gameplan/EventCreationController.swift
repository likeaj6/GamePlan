//
//  MasterViewController.swift
//  flare.io
//
//  Created by Jason Jin on 9/17/16.
//  Copyright © 2016 Jason Jin. All rights reserved.
//



import UIKit
import CoreData
import GoogleMaps
import GooglePlaces
import CoreLocation
import Firebase

class EventCreationController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //@IBOutlet weak var flareCreation: UIView!
    @IBOutlet weak var creatingPin: UIImageView!
    @IBOutlet var mapView: GMSMapView!
    
    var currentLocation: CLLocation?
    var currentCoordinate: CLLocationCoordinate2D?
    
    var cameraPosition: CLLocationCoordinate2D?
    
    var currentAddress: GMSAddress?
    var geocodedAddress: GMSAddress?
    
    var locationManagerOn = false
    var updatingLocation = false
    var creatingEvent = false
    var mapIsIdle = false
    var pressedMyLocation = false
    var doneGeocoding = false
    
    var pageViewController: EventCreationPageViewController!
    var flareCreation: UIView!
    
    //set to false initially until user has a coordinate, title, and date.
    var readyToSend = true
    
    //var currentUser: User!
    var currentEvent: Event?
    
    @IBOutlet weak var locationText: UITextField!

    let locationManager = CLLocationManager()
    
    var uid: String?
    
    //MARK: View Loading
    
    override func loadView() {
        super.loadView()
        getInitialLocation()
        print("Updating location: \(updatingLocation)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //flareCreation.isHidden = false
        
        pageViewController = (self.storyboard!.instantiateViewController(withIdentifier: "pageView")) as! EventCreationPageViewController
        self.addChildViewController(pageViewController!)
        flareCreation = pageViewController.view
        flareCreation.frame = CGRect(x: 0.0, y: 400, width: 375, height: 198)
        self.view.addSubview(flareCreation)
        pageViewController?.didMove(toParentViewController: self)
        creatingEvent = true
        mapView.delegate = self
        print("Map Loaded!")
        mapView.animate(toZoom: 20)
        mapView.isMyLocationEnabled = true
        uid = (FIRAuth.auth()?.currentUser?.uid)!
        //mapView.settings.myLocationButton = true
        print("Loaded default map")
        print("my location: \(mapView.myLocation)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //populateMapWithEvents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendEvent" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let eventConfirmationController = destinationNavigationController.topViewController as? EventConfirmationViewController
            let eventDetails = pageViewController.setEventDetails()
            currentEvent = Event(title: eventDetails[0], addedBy: uid!, coordinate: cameraPosition!, description: eventDetails[3], start: eventDetails[1], end: eventDetails[2])
            currentEvent!.setLocation(location: locationText.text!)
            print("\(currentEvent)")
            print("\(eventConfirmationController)")
            eventConfirmationController?.newEvent = self.currentEvent!
            print("\(eventConfirmationController?.newEvent)")
            print("set eventConfirmController's event")
        }
    }
    
    @IBAction func send() {
        if(readyToSend) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveEventLocally"), object: nil)
            //currentEvent = Event()
            //let result = fetchRecordsForEntity(entity: "EventLatLng", inManagedObjectContext: getContext())
            //print("\(result)")
            //deleteRecords()
        }
    }
    //let uid = FIRAuth.auth()?.currentUser?.uid
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }

    
    //MARK: UI functions
    
    func passAddress() -> GMSAddress {
        
        print("passed geocodedAddress to delegate")
        return geocodedAddress!
    }
    
    func passEventCoordinate() -> CLLocationCoordinate2D {
        if (cameraPosition != nil) {
            return cameraPosition!
        } else {
            return currentCoordinate!
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        self.doneGeocoding = false
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                self.geocodedAddress = address
                self.doneGeocoding = true
                print("doneGeocoding")
                if self.creatingEvent {
                    self.locationText.text = address.lines?[0]
                }
                
                
                
                // let lines = address.lines ! [String]
                // placemark = lines.joined(separator: "\n")
            }
        }
    }
    //MARK: GMSDelegateMethods
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("Map will move!")
        mapIsIdle = false
        locationText.isHidden = true
        flareCreation.isHidden = true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        cameraPosition = position.target
    }
    
    /**
     * Called when the map becomes idle, after any outstanding gestures or
     * animations have completed (or after the camera has been explicitly set).
     */
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("Map is Idle!")
        mapIsIdle = true
        locationText.isHidden = false
        flareCreation.isHidden = false
        if pressedMyLocation {
            if currentAddress != nil {
                geocodedAddress = currentAddress!
                pressedMyLocation = false
                return
            }
        }
        cameraPosition = position.target
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        pressedMyLocation = true
        print("Tapped Button!")
        return false
    }
    
    //MARK: LocationManager Methods
    
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
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message:
            "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        present(alert, animated: true, completion: nil)
        alert.addAction(okAction)
    }
    
    func calculateCoordinateFromLocation(location: CLLocation) -> CLLocationCoordinate2D {
        print("calculated coordinate from location \(currentCoordinate)")
        return location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let camera = GMSCameraPosition.camera(withLatitude: 0.0000, longitude: 0.0000, zoom: 5)
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
        print("didUpdateLocations \(newLocation)")
        if currentLocation == nil || currentLocation!.horizontalAccuracy > newLocation.horizontalAccuracy {
            currentLocation = newLocation
            let newCoordinate = calculateCoordinateFromLocation(location: currentLocation!)
            currentCoordinate = newCoordinate
            doneGeocoding = false
            reverseGeocodeCoordinate(coordinate: currentCoordinate!)
            currentAddress = geocodedAddress
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
