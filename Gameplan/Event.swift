//
//  Event.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

struct Position {
    var uid:String
    var lat:Double
    var lng:Double
}

struct Event {
    var uid: String?
    var title: String
    var coordinate: CLLocationCoordinate2D
    var latitude: Double
    var longitude: Double
    var location = "Not Available"
    var host: String
    var start: String
    var end: String
    var eventDescription = "N/A"
    enum eventType {
        case Public
        case Private
        case Promoted
    }
    // Here is the method the users call:
    // This class collects parameters before calling init
    init(title: String, addedBy: String, coordinate: CLLocationCoordinate2D, description:String, start: String, end: String) {
        self.uid = "0"
        self.title = title
        self.host = addedBy
        self.eventDescription = description
        self.coordinate = coordinate
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        //self.coordinate = CLLocationCoordinate2D(latitude: (eventLatitude as NSString).doubleValue, longitude: (eventLongitude as NSString).doubleValue)
        self.start = start
        self.end = end
    }
    mutating func withStartEndTime(title: String, start: String, end: String) {
        self.title = title
        self.start = start
        self.end = end
    }
    mutating func setLocation(location: String) {
        self.location = location
    }
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! NSDictionary
        //self.uid = snapshot.key as! String
        self.uid = "0"
        self.title = snapshotValue["event_title"] as! String
        self.eventDescription = snapshotValue["event_description"] as! String
        self.location = snapshotValue["event_location"] as! String
        self.host = snapshotValue["event_host"] as! String
        self.longitude = snapshotValue["event_longitude"] as! Double
        self.latitude = snapshotValue["event_latitude"] as! Double
        self.start = snapshotValue["event_start"] as! String
        self.end = snapshotValue["event_end"] as! String
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func toAnyObject() -> Any {
        return [
            "event_title": title,
            "event_description": eventDescription,
            "event_location": location,
            "event_host": host,
            "event_latitude": latitude,
            "event_longitude": longitude,
            "event_coordinate": "\(coordinate)",
            "event_start": start,
            "event_end": end
        ]
    }

    
}


