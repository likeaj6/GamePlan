//
//  LoginViewController.swift
//  flare.io
//
//  Created by Jason Jin on 10/27/16.
//  Copyright © 2016 Jason Jin. All rights reserved.
//

import UIKit
import Firebase
//import FirebaseAuth
//import FirebaseFacebookAuthUI
import FBSDKCoreKit
import FBSDKLoginKit
import DigitsKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    private let dataURL = "https://flaremap.firebaseio.com/"
    var kFacebookAppID = "04330c96f9c72b53d5d6a0c87beefb09"
    
    func successfullyLoggedIn() {
        //animate a confirmation popup
        //ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).setValue(user)
        let nextView = (self.storyboard?.instantiateViewController(withIdentifier: "MapTable"))! as UIViewController
        self.present(nextView, animated: false, completion: nil)
        //self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded view!")
        //if (((FBSDKAccessToken.current())) == nil) {
            let fbLoginButton = FBSDKLoginButton()
            self.view.addSubview(fbLoginButton)
            fbLoginButton.frame = CGRect(x: 70, y: 476, width: view.frame.width - 140, height: 38)
            fbLoginButton.delegate = self
            fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        //}
        if FIRAuth.auth()?.currentUser != nil {
            print("already logged in")
            //self.successfullyLoggedIn()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
         if (((FBSDKAccessToken.current())) != nil) {
         print("Already logged into Facebook!")
            self.successfullyLoggedIn()
         }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error.localizedDescription)
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            let uid = user!.uid
            let ref = FIRDatabase.database().reference(fromURL: "https://flaremap.firebaseio.com/").child("users").child("\(uid)")
            let userRef = FIRDatabase.database().reference(withPath: "/users/")
            userRef.observeSingleEvent(of: FIRDataEventType.value,with: { (snapshot) in
                if !snapshot.hasChild(uid) {
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
                    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                        
                        if ((error) != nil) {
                            // Process error
                            print("Error: \(error)")
                        } else {
                            print("fetched user: \(result)")
                            // set values for assignment in our Firebase database
                            let values = result
                            // update our databse by using the child database reference above called usersReference
                            
                            
                            ref.updateChildValues(values as! [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                                // if there's an error in saving to our firebase database
                                if err != nil {
                                    print(err)
                                } else {
                                    self.successfullyLoggedIn()
                                }
                                print("Save the user successfully into Firebase database")
                            })
                        }
                    })
                } else {
                    self.successfullyLoggedIn()
                }
            })
            print("Successfully logged in with facebook...")
        }
    }
}
