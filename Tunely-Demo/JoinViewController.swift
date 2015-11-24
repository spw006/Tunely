//
//  JoinViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/2/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit
import PubNub

class JoinViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var streams : JSON = nil
    var streamList : [TunelyStream] = []
    var pubnubChannels : [String] = []
    var passwordTextField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Populate the table view with streams
        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams"
        let headers : [String: String] = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        Alamofire.request(.GET, uri, headers:headers)
            .responseJSON { json in
                
                let streams = JSON(data: json.data!)
                
                print(streams)
                
                self.streams = streams
                
                // Do not proceed if server did not respond
                if (streams == nil) {
                    print("No response from server.")
                    return
                }
                
                var activeStreams: [TunelyStream] = []
                
                for (_, stream) in streams {
                    
                    let streamID = stream["_id"].stringValue
                    let streamUpdatedAt = stream["updatedAt"].stringValue
                    let streamCreatedAt = stream["createdAt"].stringValue
                    let streamPassword = stream["password"].stringValue;
                    let streamChannelName = stream["pubnub"].stringValue;
                    let streamHost = stream["host"].stringValue
                    let streamName = stream["name"].stringValue
                    
                    let tunelyStream = TunelyStream(id: streamID, updatedAt: streamUpdatedAt, createdAt: streamCreatedAt, password: streamPassword, pubnub: streamChannelName, host: streamHost, name: streamName);
                    
                    activeStreams.append(tunelyStream)
                }
                
                self.streamList = activeStreams
                
                // re-populate the table view with the data received
                self.tableView.reloadData()
        }
    }
    
    @IBAction func cancel() {
        firstLoad = true;
        
        dismissViewControllerAnimated(true, completion: nil)        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return streamList.count
    }
    
    /* Popuate table view */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = streamList[indexPath.row].name
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 20)
        
        return cell
    }
    
    /* Handle cell touches */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let tunelyStream : TunelyStream = streamList[indexPath.row]
        
        func enterStream() {
            // stream has no password
            // subscribe to the channel
            appDelegate.client?.subscribeToChannels([tunelyStream.pubnub], withPresence: true)
            
            // go to streamview
            let streamView:JoinStreamViewController = JoinStreamViewController(nibName: "JoinStreamViewController", bundle: nil)
            streamView.streamName = self.streamList[indexPath.row].name
            self.presentViewController(streamView, animated: true, completion: nil)
        }
        
        // stream has a password
        if (tunelyStream.password != "") {
            func checkPassword (entered: String, alert : UIAlertController) {
                print(entered);
                
                // password is good! proceed
                if (entered == self.streamList[indexPath.row].password) {
                    enterStream()
                }
                    
                    // incorrect password
                else {
                    alert.message = "Wrong password. Please try again."
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
            
            let alert = UIAlertController(title: self.streamList[indexPath.row].name, message: "Enter Password", preferredStyle: UIAlertControllerStyle.Alert)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {(action) in
                print(action)
            }
            
            // Enter action
            let enterAction = UIAlertAction(title: "Enter", style: UIAlertActionStyle.Default) {(action) in
                checkPassword(self.passwordTextField!.text!, alert: alert)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(enterAction)
            
            // Configure alert
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                self.passwordTextField = textField!
                textField.placeholder = "password"
                textField.secureTextEntry = true
            })
            
            // Show alert
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // stream has no password
        // subscribe to the channel
        enterStream()
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
