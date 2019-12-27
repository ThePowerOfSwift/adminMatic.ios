//
//  Login.swift
//  AdminMatic2
//
//  Created by Nicholas Digiando on 11/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation
import ObjectMapper


class Login:Codable, Mappable {
    
    enum CodingKeys : String, CodingKey{
        case attempt
        case lastAttempt
    }

    var attempt: String?
    var lastAttempt: String?
   
    init(_attempt:String, _lastAttempt: String) {
        self.attempt = _attempt
        self.lastAttempt = _lastAttempt
        
    }
    
    
    required init?(map: Map) {
       }
    
    
    
    func mapping(map: Map) {
    print("Mapping")
        attempt    <- map["attempt"]
        lastAttempt    <- map["lastAttempt"]
        
    }
    
   
    
}




