//
//  ContactTypeArray.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation


class ContactTypeArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        case contactTypes
    }
    var contactTypes: [ContactType]
    
    init(_contactTypes:[ContactType]) {
        self.contactTypes = _contactTypes
    }
    
}


