//
//  UserPicture.swift
//  Tunely-Demo
//
//  Created by Tracy Nham on 11/22/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit

class UserPicture: NSObject {
    var picURL : String!
    var name : String!
    
    override init() {
        self.picURL = "";
        self.name = "";
    }
    
    func toSerializableData() -> AnyObject {
        return [
            "picURL": NSString(string: picURL),
            "name": NSString(string: name)
        ]
    }

}
