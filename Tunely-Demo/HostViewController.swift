//
//  HostViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/2/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import SwiftyJSON

import UIKit

class HostViewController: UIViewController {
    
    // Stream object
    var newStream : NSMutableDictionary = [ "name" : "", "password" : "" ]
    
    // UI elements
    @IBOutlet weak var isPrivateStream : UISwitch!
    @IBOutlet weak var passwordField : UITextField!
    @IBOutlet weak var passwordPrompt : UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("userid: " + defaults.stringForKey("userid")!)
        
        // initially hide the private stream options
        passwordPrompt.hidden = true
        passwordField.hidden = true
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewStream(sender: AnyObject) {
        
        // Create a pubnub channel and subscribe to it
        let userid = defaults.stringForKey("userid")!
        let channelName = userid + "stream"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.client?.subscribeToChannels([channelName], withPresence: true)
        
        // create a stream for the user
        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams"
        let parameters : [String: AnyObject] = [
            "name": "New Stream",
            "host": userid,
            "pubnub": channelName,
            "password": 123 //check if there even is a password
        ]
        let headers : [String: String]? = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        Alamofire
            .request(.POST, uri, parameters: parameters, headers:headers)
            .responseJSON { json in
                
                let stream = JSON(data: json.data!)
                
                print(stream)
                
                let errors : Bool = (stream["errors"] != nil)
                let duplicate : Bool = (stream["code"] == 11000)
                
                // Do not proceed if server is not running
                if (stream == nil) {
                    print("server is not running")
                    return
                }
                
                // Do not proceed if a user already has a stream created
                if (duplicate) {
                    print("User already has a stream")
                    return;
                }
                
                // Do not proceed if there was an error during the POST request
                else if (errors) {
                    print("Error POST stream")
                    return;
                }
                    
                // stream was created, proceed to the stream view
                else {
                    print("SUCCESSFUL POST stream")
                    
                    defaults.setObject(channelName, forKey: "stream")
                    let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
                    self.presentViewController(streamView, animated: true, completion: nil)
                }
        }
    }
    
    @IBAction func changeSlider() {
        if isPrivateStream.on == false {
            
            // slider turned OFF
            passwordPrompt.hidden = true
            passwordField.hidden = true
            if passwordField.isFirstResponder() {
                passwordField.resignFirstResponder()
            }
        }
        else {
            
            // slider turned ON
            passwordPrompt.hidden = false
            passwordField.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
