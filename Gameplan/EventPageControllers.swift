//
//  EventPage1.swift
//  Geoflare
//
//  Created by Jason Jin on 1/14/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase
import CoreLocation

protocol page2 {
    var eventDescription: String { get }
}

protocol page3 {
}

protocol EventPageProtocol {
    func returnDetails() -> [String]
}

extension UIViewController : EventPageProtocol {
    func returnDetails() -> [String] {
        return []
    }
}

class EventPageController1: UIViewController{
    var current = Date()
    var pageId: String!
    //@IBOutlet weak var eventDescription: UITextField!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var eventTime: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageId = self.restorationIdentifier!
    }
    
    func showDateTimePicker(_ sender: Any) {
        let min = Date().addingTimeInterval(-60)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(selected: current, minimumDate: min, maximumDate: max, timeInterval: 5)
        picker.highlightColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
        picker.doneButtonTitle = "DONE!"
        picker.todayButtonTitle = "Today"
        picker.completionHandler = { date in
            self.current = date
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/YYYY HH:mm"
            self.eventTime.text = formatter.string(from: date)
        }
    }
    
    func returnTitle() -> String {
        if let title = eventTitle.text {
            return title
        }
        return "N/A"
    }
    func returnTime() -> String {
        if let title = eventTime.text {
            return title
        }
        return "N/A"
    }
    override func returnDetails() -> [String] {
        var eventDetails: [String] = []
        eventDetails.append(returnTitle())
        eventDetails.append(returnTime())
        eventDetails.append(returnTime())
        return eventDetails
    }
}
class EventPageController2: UIViewController {
    var loadedView = false
    var pageId: String!
    @IBOutlet weak var eventDescription: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadedView = true
        //eventDescription.text = "N/A"
        pageId = self.restorationIdentifier!
    }/*
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        self.eventDescription.text = "N/A"
    }*/
    func returnDescription() -> String {
        if loadedView {
            return eventDescription.text!
        }
        return "N/A"
    }
    override func returnDetails() -> [String] {
        var eventDetails: [String] = []
        eventDetails.append(returnDescription())
        return eventDetails
    }
}
class EventPageController3: UIViewController {
    var pageId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageId = self.restorationIdentifier!
    }
    override func returnDetails() -> [String] {
        return []
    }
}

