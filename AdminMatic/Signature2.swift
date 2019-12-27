//
//  Signature2.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/10/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class Signature2:Codable {
    
    enum CodingKeys: String, CodingKey{
           case contractId
           case type
           case path
          }
    
    var contractId: String
    var type: String //1 = customer, 2 = company
    var path: String
    
     init(_contractID: String,_type:String, _path:String) {
        self.contractId = _contractID
        self.type = _type
        self.path = _path
    }
}
