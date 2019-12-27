//
//  InspectionQuestion2.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//


 
import Foundation
import SwiftyJSON
import ObjectMapper


class InspectionQuestion2:Codable, Mappable{
    
    
    enum CodingKeys : String, CodingKey{
        case ID
        case name
        case answer
    }
    
    var ID: String?
    var name: String?
    var answer: String?
    
    
    init(_ID:String, _name: String) {
        self.ID = _ID
        self.name = _name
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        print("Mapping")
        ID    <- map["ID"]
        name    <- map["name"]
        answer    <- map["answer"]
        
    }
        
        
}

