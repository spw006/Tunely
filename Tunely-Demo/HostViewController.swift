//
//  HostViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/2/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit

class HostViewController: UIViewController {
    @IBOutlet weak var hostBtn: UIButton!
    
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func host(sender: AnyObject) {
        let streamView:StreamViewController = StreamViewController(nibName: "StreamViewController", bundle: nil)
        self.presentViewController(streamView, animated: true, completion: nil)
        
        let name = "stream name"
        let password = "password"
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        appDelegate.client?.subscribeToChannels(["my_channel"], withPresence: true)

        // post request
        
        /*let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams"
        let parameters : [String: String] = ["name": name, "password": password, "host": , "pubnub": ]
        let headers : [String: String]? = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        Alamofire.request(.POST, uri, parameters: parameters, headers:headers, encoding: .JSON)
            .responseJSON {response in
                print(response)
        } */
        
        
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
