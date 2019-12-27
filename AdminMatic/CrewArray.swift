//
//  CrewArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 11/24/19.
//  Copyright © 2019 Nick. All rights reserved.
//


class CrewArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case crews
        
    }
    
    var crews: [Crew2]
    
    
    
    init(_crews:[Crew2]) {
        self.crews = _crews
    }
    
}

