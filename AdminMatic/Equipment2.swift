//
//  Equipment2.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation

class Equipment2: Codable {
    
    enum CodingKeys : String, CodingKey{
        case ID
        case name
        case status
        case type
        
        case make
        case model
        case serial
        case crew
        case crewName
        case typeName
        case fuelType
        case fuelTypeName
        case engineType
        case engineTypeName
        case mileage
        case dealer
        case dealerName
        case purchaseDate
        case description
        case image
        
    }
    
    
    
    var ID: String
    var name: String
    var status: String
    var type: String
    
    var make: String?
    var model: String?
    var serial: String?
    var crew: String?
    var crewName: String?
    var typeName: String?
    var fuelType: String?
    var fuelTypeName: String?
    var engineType: String?
    var engineTypeName: String?
    var mileage: String?
    var dealer: String?
    var dealerName: String?
    var purchaseDate: String?
    var description: String?
    var image:Image2?

    init(_ID:String, _name: String, _status:String, _type:String) {
            self.ID = _ID
            self.name = _name
            self.status = _status
            self.type = _type
    }
    
}


