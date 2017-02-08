//
//  ViewController.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

class MapTableViewController: UIViewController{
    
    var navHeight:CGFloat { return 64.0 }
    var width:CGFloat { return self.view.bounds.size.width }
    var halfHeight:CGFloat {return (self.height - self.navHeight)*0.67}
    var height:CGFloat { return self.view.bounds.size.height }
    
    var firstPosition = true
    var userEvents = [Event]()
    var bigMap = false
    
    var uid: String?
    var eventsRef: FIRDatabaseReference?
    
    var mapView: GMSMapView?
    
    @IBOutlet weak var leftButton: UIButton!
    
    
    func toggleMenu() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
        print("toggled menu")
        FIRDatabase.database().reference(withPath: "/users/").child("\(uid!)").child("username").removeValue()
        FIRDatabase.database().reference(withPath: "/users/").child("\(uid!)").child("events").removeValue();
        setEventCollection(userEvents)
        
    }

    @IBAction func leftButtonAction() {
        if bigMap {
            self.leftButton.setImage(UIImage(named:"ic_menu"), for: .normal)
            self.mapViewController.animateToCurrentCoordinate()
            UIView.animate(withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 20.0,
            options: UIViewAnimationOptions.curveEaseIn ,
            animations: {
            self.mapViewController.view.frame = CGRect(x: 0.0, y: 64, width: self.width, height: self.halfHeight)
            self.mapViewController.mapView.frame = CGRect(x: 0.0, y: 0, width: self.width, height: self.halfHeight)
            self.tableController.view.center = CGPoint(x: self.tableController.view.center.x, y: self.tableController.view.center.y-self.halfHeight);
            },
            completion:{ (Bool)  in
            //self.leftButton = nil
            self.bigMap = false
            self.mapViewController.mapView.selectedMarker = nil
            //let coordinate = CLLocationCoordinate2DMake(39.903381, -75.356908)
            //self.mapViewController.mapView.animate(toLocation: coordinate)
        })
        } else {
            toggleMenu()
        }
        
    }
    @IBAction func backFromEventCreation(segue: UIStoryboardSegue) {
    }

    lazy var mapViewController:MapViewController = {
        let m =  MapViewController(frame: CGRect(x: 0.0, y: self.navHeight, width: self.width, height: self.halfHeight))
        m.view.addGestureRecognizer(self.tapFirstView)
        self.mapView = m.mapView
        return m
    }()
    
    lazy var tapFirstView:UIGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(MapTableViewController.mapViewTapped))
    }()
    
    lazy var tableController:EventsTableViewController = {
        return EventsTableViewController(frame: CGRect(x: 0.0, y: self.halfHeight, width: self.width, height: self.halfHeight))
    }()
    
    lazy var detailEvent:EventDetailViewController = {
        return EventDetailViewController()
    }()
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789").inverted
        return string.rangeOfCharacter(from: set) == nil
    }
   
    
    func initialSetUp() {
        print("initially set up")
        let userRef = FIRDatabase.database().reference(withPath: "/users/").child("\(uid!)")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("observing event")
            print("\(snapshot)")
            
            if snapshot.hasChild("username"){
               print("user has username")
            } else {
                print("user does not have username")
                //do stuff
                let nameRef = FIRDatabase.database().reference(withPath: "/usernames/")
                let alert = SCLAlertView()
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleFont: UIFont(name: "Futura-Medium", size: 20)!,
                    kTextFont: UIFont(name: "Futura-Medium", size: 14)!,
                    kButtonFont: UIFont(name: "Futura-Bold", size: 14)!,
                    showCloseButton: false,
                    shouldAutoDismiss: false
                )
                alert.appearance = appearance
                let newName = alert.addTextField("Enter your name")
                alert.addButton("Check name", backgroundColor: UIColor.black, textColor: UIColor.white, showDurationStatus: false) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    if let name = newName.text {
                        if name != "" {
                        //check if username is unique
                            nameRef.child(name.lowercased()).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                                print("\(snapshot.value)")
                                if !snapshot.exists() {
                                    let alertView = SCLAlertView()
                                    alertView.showSuccess("Woohoo!", subTitle: "This username is valid!")
                                    print("valid username")
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Sorry :(", subTitle: "This username has already been taken.")
                                }
                            })
                        } else {
                            let alertView = SCLAlertView()
                            alertView.showError("Sorry :(", subTitle: "Your name can't be blank!")
                        }
                    }
                    
                }
                alert.addButton("Done", backgroundColor: UIColor.black, textColor: UIColor.white, showDurationStatus: false) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                    if let name = newName.text {
                        if name != "" {
                            //check if username is unique
                            nameRef.child(name.lowercased()).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                                print("\(snapshot.value)")
                                if !snapshot.exists() {
                                    alert.hideView()
                                    let alertView = SCLAlertView()
                                    alertView.showSuccess("Success!", subTitle: "You're all set to go!")
                                    userRef.child("username").setValue(name)
                                    nameRef.updateChildValues([name.lowercased(): self.uid])
                                } else {
                                    let alertView = SCLAlertView()
                                    alertView.showError("Sorry :(", subTitle: "This username has already been taken.")
                                }
                            })
                        } else {
                            let alertView = SCLAlertView()
                            alertView.showError("Sorry :(", subTitle: "Your name can't be blank!")
                        }
                    }
                }
                alert.showCustom("Username", subTitle: "Please pick a user name!", color: UIColor.black, icon: SCLAlertViewStyleKit.imageOfEdit)
            }
        })
        //userRef.removeObserver(withHandle: newRefHandle)
    }
    //convenience init(frame:CGRect){
    override func viewDidLoad() {
        //self.init(nibName: nil, bundle: nil)
        self.view.addSubview(self.mapViewController.view)
        self.view.addSubview(self.tableController.view)
        print("View did load")
        title = "Gameplan"
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapTableViewController.mapViewTapped), name: NSNotification.Name(rawValue: "mapViewTapped"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapTableViewController.navigateToDetail(_:)), name: NSNotification.Name(rawValue: "navigateToDetail"), object: nil)
        
        let coordinate = CLLocationCoordinate2DMake(39.904105, -75.354751)
        uid = (FIRAuth.auth()?.currentUser?.uid)!
        eventsRef = FIRDatabase.database().reference(withPath: "/users/").child("\(uid)").child("events")
        //let e = Event(title: "Swag", addedBy: "swag", coordinate: coordinate, description: "lit", start: "10:00", end: "12:00"
        //userEvents.append(e)
        initialSetUp()
        fetchEvents()
    }
    
    func mapViewTapped(){
        print("map view tapped!")
        if (!bigMap){
            self.leftButton.setImage(UIImage(named:"ic_chevron_left"), for: .normal)
            print("not big map")
            print("setTitle")
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 20.0,
                           options: UIViewAnimationOptions.curveEaseIn ,
                           animations: {
                            self.mapViewController.view.frame = CGRect(x: 0.0, y: 64, width: self.width, height: self.height)
                            self.mapViewController.mapView.frame = CGRect(x: 0.0, y: 0, width: self.width, height: self.height)
                            self.tableController.view.center = CGPoint(x: self.tableController.view.center.x, y: self.tableController.view.center.y+self.halfHeight);
            },
                           completion:{ (Bool)  in
                           self.bigMap = true
            })
            
        }
    }
    
    func reverse(){
        if bigMap {
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 20.0,
                           options: UIViewAnimationOptions.curveEaseIn ,
                           animations: {
                            self.mapViewController.view.frame = CGRect(x: 0.0, y: self.navHeight, width: self.width, height: self.halfHeight)
                            self.mapViewController.mapView.frame = CGRect(x: 0.0, y: self.navHeight, width: self.width, height: self.halfHeight)
                            self.tableController.view.center = CGPoint(x: self.tableController.view.center.x, y: self.tableController.view.center.y-self.halfHeight);
            },
                           completion:{ (Bool)  in
                            self.bigMap = false
                            self.mapViewController.mapView.selectedMarker = nil
                            //let coordinate = CLLocationCoordinate2DMake(39.903381, -75.356908)
                            //self.mapViewController.mapView.animate(toLocation: coordinate)
                            self.mapViewController.didTapMyLocationButton(for: self.mapView!)
            })
        }
        
    }
    
    func fetchEvents() {
        print("fetching events")
        FIRDatabase.database().reference().child("users").child(uid!).child("events").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let event = Event(snapshot: snapshot)
                self.userEvents.append(event)
                print("printing event: \(event)")
            }
            self.setEventCollection(self.userEvents)
        }, withCancel: nil)
    }
    func setEventCollection(_ array: [Event]!) {
        if let e = array {
            userEvents = e
            tableController.loadEvents(e)
            mapViewController.loadMarkersWithArray(e)
        }
    }
    
    func navigateToDetail(_ notification:Notification){
        if let event = notification.object as? Event {
            self.detailEvent.lblTitle.text = event.title
            self.detailEvent.lblLocation.text = event.location
            self.detailEvent.lblDescription.text = event.eventDescription
            
        } else {
            print("no event at MapTableController")
        }
        self.navigationController?.pushViewController(self.detailEvent, animated: true)
    }
    
    
}
