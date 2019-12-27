//
//  ImageArray.swift
//  AdminMatic2
//
//  Created by Nick on 7/12/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

class ImageArray: Codable {
    
    enum CodingKeys : String, CodingKey {
        
        case images
        
        case thumbBase
        case mediumBase
        case rawBase
        
       
        
        
    }
    
    var images: [Image2]
    
    var thumbBase:String? = ""
    var mediumBase:String? = ""
    var rawBase:String? = ""
    
    
    
    
    init(_images:[Image2]) {
        self.images = _images
    }
    
}



