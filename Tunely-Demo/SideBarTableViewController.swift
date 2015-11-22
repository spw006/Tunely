//
//  SideBarTableViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 10/17/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKLoginKit

class SideBarTableViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var sideBarArray : [ String ] = [ "Home", "Logout", "End Stream" ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return sideBarArray.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = sideBarArray[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Helvetica", size: 30)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if sideBarArray[indexPath.row] == "Home" {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc : UIViewController = storyBoard.instantiateViewControllerWithIdentifier("mainIdent")
            self.presentViewController(vc, animated: false, completion: nil)
        }
        
        if sideBarArray[indexPath.row] == "End Stream" {
            let hostedStream = defaults.stringForKey("hostedStream")
            
            // delete the current stream
            if (hostedStream != nil) {
                let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams/" + hostedStream!
                let headers : [String: String] = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
                
                Alamofire.request(.DELETE, uri, headers:headers)
                    .responseJSON { json in
                        
                        let deletedStream = JSON(data: json.data!)
                        
                        print (deletedStream)
                        
                        // Do not proceed if server did not respond
                        if (deletedStream == nil) {
                            print("No response from server or stream does not exist.")
                            return
                        }
                        
                        // delete the value for the hostedStream key
                        defaults.setObject(nil, forKey: "hostedStream")
                        
                        print("Deleted hosted stream.")
                }
                
                // unsubscribe from pubnub
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let targetChannel = appDelegate.client?.channels().last {
                    print("unsubscribed from " + (targetChannel as! String))
                    appDelegate.client?.unsubscribeFromChannels([targetChannel as! String], withPresence: true)
                }
                
                
                // go back to home after delete
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let vc : UIViewController = storyBoard.instantiateViewControllerWithIdentifier("mainIdent")
                self.presentViewController(vc, animated: false, completion: nil)
            }
            
            // the user is not in a stream
            else {
                print("No current stream")
                dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        if sideBarArray[indexPath.row] == "Logout" {
            FBSDKLoginManager().logOut()
            let view:ViewController = ViewController(nibName: "ViewController", bundle: nil)
            //self.presentViewController(view, animated: true, completion: nil)
            dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func  dismissSideBar(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
