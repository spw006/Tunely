//
//  ViewController.swift
//  Tunely-Demo
//
//  Created by Tracy Nham on 10/15/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//


import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Alamofire

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginView : UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*navigationController!.navigationBar.barTintColor = UIColor(red: 77.0/255.0, green: 182.0/255.0, blue: 172.0/255.0, alpha: 1.0) */

        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
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
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                returnUserData()
            }
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,email,name,friends, picture.width(480).height(480)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
                
                
                let userFriends: NSDictionary = result.valueForKey("friends") as! NSDictionary
                print("User Friends are: \(userFriends)")
                
                let userFBID: NSString = result.valueForKey("id") as! NSString
                
                let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/users"
                
                let parameters : [String: AnyObject] = ["name": userName, "email": userEmail , "fbid": userFBID]
                let headers : [String: String]? = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
                
                Alamofire.request(.POST, uri, parameters: parameters, headers:headers, encoding: .JSON)
                    .responseJSON {response in
                        print(response)
                }
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.userFBID = userFBID
            }
        })
        
//        let request = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
//        
//        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
//            if error == nil {
//                print("Friends are : \(result)")
//            } else {
//                print("Error Getting Friends \(error)");
//            }
//        }
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
        if let _ = FBSDKAccessToken.currentAccessToken()
        {
            // user is logged in
            loginView.alpha = 0
        }
        else
        {
            // user is logged out
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(1)
            UIView.setAnimationDelay(0.2)
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseOut)
            loginView.alpha = 1
            
            UIView.commitAnimations()
        }
        
    }
    
}



