//
//  UserPicture.swift
//  
//
//  Created by Tracy Nham on 11/22/15.
//
//

import UIKit

class UserPicture: NSObject {
    
    var picture : UIImage?
    var user : String?
    
    init(picture : UIImage, user : String) {
        self.picture = picture;
        self.user = user;
    }

}
