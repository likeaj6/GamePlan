//
//  EventsTableViewController.swift
//  Gameplan
//
//  Created by Jason Jin on 1/19/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import UIKit

class EventsTableViewController: UITableViewController {
    
    var events = [Event]()
    var rightButton:UIButton?
    let cellId = "cell"
    
    convenience init(frame:CGRect){
        self.init(style:.plain)
        self.title = "Plain Table"
        self.view.frame = frame
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FoldingCell.self, forCellReuseIdentifier: self.cellId)
        self.tableView.rowHeight = 110
    }
    
    func loadEvents(_ array: [Event]) {
        print("loading events 1")
        self.events = array
        print("\(events)")
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("loading table cells")
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath)
        
        let event = self.events[(indexPath as NSIndexPath).row] as Event
        cell.textLabel!.text = event.title
        print("event description: \(event.eventDescription)")
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print((indexPath as NSIndexPath).row)
        let cell = self.tableView.cellForRow(at: indexPath) as UITableViewCell?
        print(cell?.textLabel?.text)
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "mapViewTapped"), object: nil)
        let event:Event = self.events[(indexPath as NSIndexPath).row] as Event
        NotificationCenter.default.post(name: Notification.Name(rawValue: "selectEvent"), object: event)
    }
    
    deinit{
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
    }
    
}
