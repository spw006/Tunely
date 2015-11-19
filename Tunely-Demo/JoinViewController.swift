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
    var streamList : [String] = []
    var pubnubChannels : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
        
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
                
                for (_, stream) in streams {
                    if let title = stream["name"].string {
                        self.streamList.append(title)
                    }
                    if let pubnub = stream["pubnub"].string {
                        self.pubnubChannels.append(pubnub)
                    }
                }
                
                // re-populate the table view with the data received
                self.tableView.reloadData()
        }
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        cell.textLabel?.text = streamList[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 20)
        
        return cell
    }
    
    /* Handle cell touches */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // subscribe to specified channel
        appDelegate.client?.subscribeToChannels([pubnubChannels[indexPath.row]], withPresence: true)
        
        // go to streamview
        let streamView:JoinStreamViewController = JoinStreamViewController(nibName: "JoinStreamViewController", bundle: nil)
        streamView.streamName = streamList[indexPath.row]
        self.presentViewController(streamView, animated: true, completion: nil)
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
