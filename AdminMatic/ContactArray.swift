//
//  ContactArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/9/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class ContactArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case contacts
        
    }
    
    var contacts: [Contact2]
    
    
    
    init(_contacts:[Contact2]) {
        self.contacts = _contacts
    }
    
}


