//
//  StreamViewController.swift
//  Tunely-Demo
//
//  Created by Cole Stipe on 11/3/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import Alamofire
import UIKit

class StreamViewController: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = "My Stream"

        // Do any additional setup after loading the view.
    }
    
    func loadStream(url: NSString) {
        // STEP 1
        // get title for url
        // populate title label with it
        
        // STEP 2
        // get songs for url
        // populate table view with them
        
        // STEP 3
        // get listeners for url
        // populate collection view with them
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func revealSideBar(sender: AnyObject) {
        
        let sideBar:SideBarTableViewController = SideBarTableViewController(nibName: "SideBarTableViewController", bundle: nil)
        sideBar.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(sideBar, animated: true, completion: nil)
        
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
