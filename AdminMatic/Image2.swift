//
//  Image2.swift
//  AdminMatic2
//
//  Created by Nick on 7/11/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation
import UIKit

class Image2:Codable {
    
    enum CodingKeys : String, CodingKey {
        case ID
        case name
        case fileName
        case width
        case height
        case description
        case customer
        case custName = "customerName"
        case woID
        case albumID = "album"
        case leadTaskID
        case contractTaskID
        case taskID
        case equipmentID
        case usageID
        case vendorID
        case dateAdded
        case createdBy = "createdByName"
        case type
        case tags
        case index
        case liked
        case likes
        
                
    }
    
    var ID: String
    var fileName: String
    var name: String
    var width: String
    var height: String
    
    var description: String = ""
    
    var customer: String? = "0"
    var custName: String? = ""
    
    var albumID: String = "0"
    var dateAdded: String = ""
    var createdBy: String? = ""
    var type: String = ""
    
    
    var woID: String? = "0"
    var leadTaskID: String? = "0"
    var contractTaskID: String? = "0"
    var taskID: String? = "0"
    var equipmentID: String? = "0"
    
    var usageID:String? = "0"
    var vendorID:String? = "0"
    
    var tags: String? = ""
    
    var thumbPath: String?
    var mediumPath: String?
    var rawPath: String?
    
    var imageData:Data?
    
    var uploadProgress:Float? = 0.0
    var uploadStatus:String? = "Uploading..."
    
    var index:Int? = 0
    var liked:String? = "0"
    var likes:String? = "0"
    
    var toBeSaved:String? = "0"
    
    //var thumbBase:String? = ""
    //var mediumBase:String? = ""
    //var rawBase:String? = ""

    
    //https:\/\/www.adminmatic.com\/uploads\/fm\/thumbs\/
    //let rawBase : String = "https://www.adminmatic.com/uploads/\(defaultsKeys.companyUnique)/general/raw/"
    //let mediumBase : String = "https://www.adminmatic.com/uploads/\(defaultsKeys.companyUnique)/general/medium/"
    //let thumbBase : String = "https://www.adminmatic.com/uploads/\(defaultsKeys.companyUnique)/general/thumbs/"
    
    let noPicPath: String = "https://www.adminmatic.com/cp/img/noImageIcon.png"
    
    
    init( _id: String, _fileName:String, _name:String, _width:String, _height:String, _description:String, _dateAdded:String, _createdBy:String, _type:String) {
        
            self.ID = _id
            self.fileName = _fileName
            self.name = _name
            self.width = _width
            self.height = _height
            self.description = _description
            if(self.description == ""){
                self.description = "No description provided."
            }
            self.dateAdded = _dateAdded
            self.createdBy = _createdBy
            self.type = _type
        
    }
    
    
    func setDefaultPath(){
        self.rawPath = noPicPath
        self.mediumPath = noPicPath
        self.thumbPath = noPicPath
    }
    
    
    
    func setImagePaths(_thumbBase:String,_mediumBase:String,_rawBase:String){
        self.thumbPath  = "\(String(describing: _thumbBase))\(self.fileName)"
        self.mediumPath  = "\(String(describing: _mediumBase))\(self.fileName)"
        self.rawPath  = "\(String(describing: _rawBase))\(self.fileName)"
    }
    
    func setEquipmentImagePaths(){
        self.rawPath = "https://adminmatic.com/uploads/general/Equipment(\(self.ID)).jpeg"
        self.mediumPath = "https://adminmatic.com/uploads/general/medium/Equipment(\(self.ID)).jpeg"
        self.thumbPath = "https://adminmatic.com/uploads/general/thumbs/Equipment(\(self.ID)).jpeg"
    }
    
    func urlStringToData(_urlString:String)->Data{
        print("url = \(_urlString)")
        let url = URL(fileURLWithPath: _urlString)
        let data = (try? Data(contentsOf: url))! //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        return data
    }
    
   
    
}


