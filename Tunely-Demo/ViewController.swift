//
//  ViewController.swift
//  Tunely-Demo
//
//  Created by Tracy Nham on 10/15/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import SwiftyJSON

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import PubNub

let defaults = NSUserDefaults.standardUserDefaults()


class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginView : UIView!
    
    let publishKey : String = "pub-c-92476f6d-6968-4061-b297-5b4de6065ecf";
    let subscribeKey : String = "sub-c-26dd82d4-8259-11e5-a4dc-0619f8945a4f";

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
            configuration.uuid = defaults.stringForKey("userFbid")
            
            appDelegate.client = PubNub.clientWithConfiguration(configuration)
            
            // User is already logged in, do work such as go to next view controller.
        }
            
        // Do any additional setup after loading the view, typically from a nib.
        else {
            let loginButton : FBSDKLoginButton = FBSDKLoginButton()
            loginView.addSubview(loginButton)
            loginButton.center = self.view.center
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, check if specific permissions missing
            if result.grantedPermissions.contains("email") {
                returnUserData()
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    
    /** Facebook Login Callback function */
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,friends, picture.width(480).height(480)"])
        
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                print("Error: \(error)")
            }
                
            else {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let configuration = PNConfiguration(publishKey: "demo", subscribeKey: "demo")
        
                let userName : NSString = result.valueForKey("name") as! NSString
                let userFbid: String = result.valueForKey("id") as! String
                let userEmail : NSString = result.valueForKey("email") as! NSString
                let userPicURL: String = result.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as! String
                //let userFriends: NSDictionary = result.valueForKey("friends") as! NSDictionary
                
                // store these variables in the defaults object on the client side
                defaults.setObject(userName, forKey: "userName")        // userName -> User name
                defaults.setObject(userFbid, forKey: "userFbid")        // userFbid -> User Facebook ID
                defaults.setObject(userEmail, forKey: "userEmail")      // userEmail -> User email
                defaults.setObject(userPicURL, forKey: "userPicURL")    // userPicURL -> User profile picture url
                
                // create PubNub
                configuration.uuid = userFbid
                appDelegate.client = PubNub.clientWithConfiguration(configuration)
                
                if (appDelegate.client != nil) {
                    print("view controller good")
                }
                
                // Attempt to create a new Facebook user
                var uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/users"
                let parameters : [String: AnyObject] = [
                    "name": userName,
                    "fbid": userFbid,
                    "email": userEmail,
                    "picture": userPicURL
                ]
                let headers : [String: String]? = [
                    "x-access-token": FBSDKAccessToken.currentAccessToken().tokenString
                ]
                
                Alamofire.request(.POST, uri, parameters: parameters, headers: headers)
                    .responseJSON { json in
                        
                        var user = JSON(data: json.data!)
                        
                        print(user);
                        
                        let errors : Bool = (user["errors"] != nil)
                        let duplicate : Bool = (user["code"] == 11000)
                        
                        // Do not proceed if server did not respond
                        if (user == nil) {
                            print("No response from server or user does not exist.")
                            return
                        }
                        
                        if (errors) {
                            print("Error POST stream.")
                            return;
                        }
                        
                        // user is already created so update the user
                        if (duplicate) {
                            print("User: " + (userName as String) + ", already exists.")
                            
                            uri = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/users/fbid/" + userFbid
                            
                            Alamofire.request(.PUT, uri, parameters: parameters, headers:headers)
                                .responseJSON { json in
                                    
                                    user = JSON(data: json.data!)
                                    
                                    print(user);
                            }
                        }
                            
                        // new user created
                        else {
                            print("New User: " + (userName as String) + ", created.")
                        }
                    }
            
            
                // store user picture
                /*let url : NSURL = NSURL(fileURLWithPath: picURL)
                let data : NSData = NSData(contentsOfURL: url)!

                let picture: UIImageView = UIImageView(image: UIImage(data: data)!)
                
                defaults.setObject(picture, forKey: "picture") */
                
            }
        })
    }
    
    @IBAction func revealSideBar(sender: AnyObject) {
        
        let sideBar:SideBarTableViewController = SideBarTableViewController(nibName: "SideBarTableViewController", bundle: nil)
        sideBar.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(sideBar, animated: true, completion: nil)
        
    }
    
    @IBAction func hostStream(sender: AnyObject) {
        let hostView:HostViewController = HostViewController(nibName: "HostViewController", bundle: nil)
        self.presentViewController(hostView, animated: true, completion: nil)
    }
    
    @IBAction func joinStream(sender: AnyObject) {
        let joinView:JoinViewController = JoinViewController(nibName: "JoinViewController", bundle: nil)
        self.presentViewController(joinView, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        //print(defaults.stringForKey("userid")!)
        
        if let _ = FBSDKAccessToken.currentAccessToken()
        {
            // user is logged in
            loginView.alpha = 0
        }
        else
        {
            //user is logged out
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1)
            UIView.setAnimationDelay(0.2)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
            loginView.alpha = 1
            
            UIView.commitAnimations()
        }
        
    }
    
}



