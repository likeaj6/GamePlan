//
//  FriendSearch.swift
//  Gameplan
//
//  Created by Jason Jin on 1/26/17.
//  Copyright © 2017 Jason Jin. All rights reserved.
//

import UIKit
import Firebase

class FriendsSearchViewController: UITableViewController, UISearchResultsUpdating {
    
    
    @IBOutlet var friendsTableView: UITableView!
    var friendsRef: FIRDatabaseReference?
    var uid: String?
    var newEvent: Event?
    var usersArray = [User]()
    var filteredUsers = [User]()
    let cellId = "friendCell"
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func addFriend(_ sender: AnyObject) {
        let button: UIButton = sender as! UIButton
        let user = filteredUsers[button.tag]
        print ("\(user)")
        let otherUid = user.uid
        print ("\(otherUid)")
        FIRDatabase.database().reference(withPath: "/users/").child(uid!).child("friends").updateChildValues([otherUid: false])
        print("added friend!")
        button.isEnabled = false
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor.black
        //FIRDatabase.database().reference(withPath: "/users/").child(otherUid).child("friends")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let address = delegate?.passAddress()
        self.tableView.register(FriendCell.self, forCellReuseIdentifier: self.cellId)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.setShowsCancelButton(false, animated: false)
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        uid = (FIRAuth.auth()?.currentUser?.uid)!
        fetchUsers()        /*
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        uid = (FIRAuth.auth()?.currentUser?.uid)!
        friendsRef = FIRDatabase.database().reference(withPath: "/users/").child(uid!).child("friends")
        fetchUser()
        print("fetched users")
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Futura", size: 17)!]*/
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterFriends(searchText: self.searchController.searchBar.text!)
    }
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        // 2
        toggleCellCheckbox(cell, isCompleted: true)
        let user = userFriends[indexPath.row]
        selectedFriend.append(user.uid)
        print("\(selectedFriend)")
    }
    
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FriendCell
        tableView.rowHeight = 66
        let user : User
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
            cell.textLabel?.text = "Jason"
            cell.detailTextLabel?.text = user.username
            cell.cellButton.tag = indexPath.row
            cell.cellButton.addTarget(self, action: #selector(FriendsSearchViewController.addFriend(_:)), for: UIControlEvents.touchUpInside)
        }
        
        /*else {
            user = self.usersArray[indexPath.row]
        }*/
        
        
        return cell
        
        
    }/*
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
    */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        //return self.usersArray.count
        return 0
    }
    
    func fetchUsers() {
        //let user = User(uid: "FJpA8PGCmwPRT9xjdrZENMIH8wJ3", email: "123", username: "likeaj6")
        //self.usersArray.append(user)
        print("fetching users")
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            print("\(snapshot)")
            let user = User(snapshot: snapshot)
            self.usersArray.append(user)
            //self.friendsTableView.insertRows(at: [IndexPath(row:self.usersArray.count-1,section:0)], with: UITableViewRowAnimation.automatic)
            print("\(user)")
            //DispatchQueue.main.async(execute: {
              //  self.tableView.reloadData()
            //})
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
    func filterFriends(searchText:String) {
        self.filteredUsers = self.usersArray.filter{ user in
            let username = user.username as? String
            return (username?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
}

class FriendCell: UITableViewCell {
    var cellButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.setTitle("Add Friend", for: .normal)
        button.setTitle("Done!", for: UIControlState.disabled)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor.black, for: .normal)
        button.setTitleColor(UIColor.white, for: .disabled)
        button.setImage(UIImage(named:"ic_person_add"), for: .normal)
        button.setImage(UIImage(named:"ic_person_add_white"), for: .disabled)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        //button.frame(CGRect(x: 250, y: 5, width: 100, height: 30))
        //        button.titleEdgeInsets = UIEdgeInsets
        return button
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: "friendCell")
        self.selectionStyle = .none
        //cellLabel.font = UIFont()
        //addButton = UIButton(frame: CGRect(x: 250, y: 5, width: 100, height: 30))
        addSubview(cellButton)
        cellButton.anchor(topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 120, heightConstant: 34)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
