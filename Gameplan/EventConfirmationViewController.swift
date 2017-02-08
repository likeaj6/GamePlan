//
//  EventDetailsViewController.swift
//  flare.io
//
//  Created by Jason Jin on 10/8/16.
//  Copyright © 2016 Jason Jin. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class EventConfirmationViewController: UITableViewController {
    var friendsRef: FIRDatabaseReference?
    var uid: String?
    var newEvent: Event?
    var userFriends = [User]()
    let cellId = "cellId"
    var didSelect = false
    let sendButton: UIButton = {
        //let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.tableView.frame.size.height - self.tableView.contentSize.height - self.footerView.frame.size.height))
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setImage(UIImage(named:"ic_arrow_forward_white"), for: .normal)
        button.backgroundColor = UIColor.black
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -10)
        return button
    }()
    var selectedFriend: [String] = []
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "returnToHome") {
//            let newEvent = Event(title: eventTitle.text!, addedBy: uid!, description: descriptionTextView.text, address: address!, latitude: latitude!, longitude: longitude!)
            
            // Push data to Firebase Database
//            FIRDatabase.database().reference(withPath: "/users/events").childByAutoId().setValue(newEvent.toAnyObject())
            print("added event to firebase!")
        }
    }
    
    func send(_ sender: AnyObject) {
        //selected users are added to the event's user list, and the event is added selected user's events
        //print("\(result)")
        if selectedFriend.count != 0 {
            let ref = FIRDatabase.database().reference(withPath: "/users/").child(uid!).child("events").childByAutoId()
            let eventID = ref.key
            let event = newEvent!.toAnyObject()
            ref.setValue(event)
            FIRDatabase.database().reference(withPath: "/events/userEvents").child(eventID).setValue(event)
            for userId in selectedFriend {
                FIRDatabase.database().reference(withPath: "/users/").child("\(userId)").child("events").child(eventID).setValue(event)
            }
        } else {
        }
        print("sending event")
        print("\(newEvent)")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "selectEvent"), object: newEvent)
        self.performSegue(withIdentifier: "returnToHome", sender: self)
    }
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let address = delegate?.passAddress()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        uid = (FIRAuth.auth()?.currentUser?.uid)!
        friendsRef = FIRDatabase.database().reference(withPath: "/users/").child(uid!).child("friends")
        tableView.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(EventConfirmationViewController.send(_:)), for: UIControlEvents.touchUpInside)
        tableView.rowHeight = 66
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.sendButton.frame = CGRect(x: 0, y: self.view.bounds.size.height - 110, width: self.view.bounds.size.width, height: 66)
        }, completion: nil)
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Futura", size: 17)!]
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchUser()
        print("fetched users")
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        // 2
        if selectedFriend.count != 0 {
            didSelect = true
        }
        toggleCellCheckbox(cell, isCompleted: true)
        let user = userFriends[indexPath.row]
        selectedFriend.append(user.uid)
        print("\(selectedFriend)")
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFriends.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let user = userFriends[indexPath.row]
        
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = "Available"
        
        return cell

        
    }
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    func fetchUser() {
        let user = User(uid: "0sj2T2S5nvazuWYBnZ84JzEBisj1", email: "123", username: "likeaj6")
        self.userFriends.append(user)
        FIRDatabase.database().reference().child("users").child(uid!).child("friend").observe(.childAdded, with: { (snapshot) in
            print("\(snapshot)")
            if snapshot.exists() {
                let user = User(snapshot: snapshot)
                self.userFriends.append(user)
                print("\(user)")
                //                user.name = dictionary["name"]
            }
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
        }, withCancel: nil)
        //friendsRef.observe(.value, with: { snapshot in
            //print("\(snapshot.children)")
            //for item in snapshot.children {
            //    print("item")
            //    let user = User(snapshot: item as! FIRDataSnapshot)
            ///    self.userFriends.append(user)
            //}
            //DispatchQueue.main.async(execute: {
            //    self.tableView.reloadData()
        //    })
        //})
    }

}

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
