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
        
        // initially hide the private stream options
        passwordPrompt.hidden = true
        passwordField.hidden = true
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func viewStream(sender: AnyObject) {
        
        // Create a pubnub channel and subscribe to it
        let userFbid = defaults.stringForKey("userFbid")!
        let userName = defaults.stringForKey("userName")!
        let streamName = userName + "'s Stream"
        let channelName = userFbid + "channel"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams"
        var parameters: [String: AnyObject] = ["name": streamName, "host": userFbid, "pubnub": channelName]
        let headers : [String: String] = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        // check for optional password field
        if (passwordField.text != nil) {
            parameters["password"] = passwordField.text
        }
        
        // create a stream
        Alamofire.request(.POST, uri, parameters: parameters, headers:headers)
            .responseJSON { json in
                
                let stream = JSON(data: json.data!)
                
                print(stream)
                
                let errors : Bool = (stream["errors"] != nil)
                let duplicate : Bool = (stream["code"] == 11000)
                
                // Do not proceed if server did not respond
                if (stream == nil) {
                    print("No response from server.")
                    return
                }
                
                // Do not proceed if there was an error during the POST request
                if (errors) {
                    print("Error POST stream.")
                    return;
                }
                
                // Do not proceed if a user already has a stream created
                if (duplicate) {
                    print("User already has a stream.")
                    return;
                }
                
                print("SUCCESSFUL POST stream to server, creating channel...")
                
                // subscribe the host to the channel
                appDelegate.client?.subscribeToChannels([channelName], withPresence: true)
                
                let streamID = stream["_id"].stringValue
                defaults.setObject(streamID, forKey: "hostedStream")
                defaults.setObject(channelName, forKey: "channelName")
                
                // go to stream view
                let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
                self.presentViewController(streamView, animated: true, completion: nil)
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
