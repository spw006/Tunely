//
//  TunelyStream.swift
//  Tunely-Demo
//
//  Created by Tracy Nham on 11/19/15.
//  Copyright © 2015 Tracy Nham. All rights reserved.
//

import UIKit

class TunelyStream: NSObject, NSCoding {
    var id : String!
    var updatedAt : String!
    var createdAt : String!
    var password : String?
    var pubnub : String!    // channel name
    var host : String!      // host's fib
    var name : String!
    
    init(id : String, updatedAt : String, createdAt : String, password : String?, pubnub : String, host: String, name : String) {
        self.id = id;
        self.updatedAt = updatedAt;
        self.createdAt = createdAt;
        self.password = password;
        self.pubnub = pubnub;
        self.host = host;
        self.name = name;
        
    }
    
    required init(coder aDecoder: NSCoder) {}
    
    func encodeWithCoder(aCoder: NSCoder) {}
}