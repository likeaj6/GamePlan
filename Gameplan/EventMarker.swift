//
//  EventMarker.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import GoogleMaps

class EventMarker : GMSMarker {
    
    var event:Event?
    
    deinit{
        self.event = nil
    }
}
