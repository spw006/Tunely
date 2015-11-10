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

class JoinViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // create a stream for the user
        let uri : String = "http://ec2-54-183-142-37.us-west-1.compute.amazonaws.com/api/streams"
        let headers : [String: String]? = ["x-access-token": FBSDKAccessToken.currentAccessToken().tokenString]
        
        Alamofire
            .request(.GET, uri, headers:headers)
            .responseJSON { json in
                
                let streams = JSON(data: json.data!)
                
                print(streams)
                
        }
        
        
    }
    
    @IBAction func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
