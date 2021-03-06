//
//  ImageUploadProgressTableViewCell.swift
//  AdminMatic2
//
//  Created by Nick on 3/20/17.
//  Copyright © 2017 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON

 
class ImageUploadProgressTableViewCell: UITableViewCell {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var imageData:Image2!
    var uiImage:UIImage!
    var uploadDelegate:ImageUploadProgressDelegate!
    let saveURLString:String = "https://www.adminmatic.com/cp/app/functions/update/image.php"
    var progressLbl: UILabel! = UILabel()
    var progressView:UIProgressView!
    var progressValue:Float!
    var selectedImageView:UIImageView = UIImageView()
    var scoreAdjust:Int?
    var layoutVars:LayoutVars = LayoutVars()
    var indexPath:IndexPath!
    var reloadBtn:UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func layoutViews(){
        print("cell layoutviews")
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        self.selectionStyle = .none
        self.selectedImageView.layer.cornerRadius = 5.0
        self.selectedImageView.clipsToBounds = true
        self.selectedImageView.contentMode = .scaleAspectFill
        self.selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.selectedImageView.image = self.uiImage
        self.contentView.addSubview(self.selectedImageView)
        
        self.progressLbl = Label(text: imageData.uploadStatus, valueMode: false)
        self.progressLbl.font = self.progressLbl.font.withSize(20)
        self.progressLbl.textAlignment = .left
        self.progressLbl.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.progressLbl)
        
        self.reloadBtn = Button()
        self.reloadBtn.translatesAutoresizingMaskIntoConstraints = false
        self.reloadBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        
        self.reloadBtn.setTitle("Reload", for: UIControl.State.normal)
        self.reloadBtn.addTarget(self, action: #selector(ImageUploadProgressTableViewCell.handleReload), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(self.reloadBtn)
        self.reloadBtn.isHidden = true
        
        self.progressView = UIProgressView()
        self.progressView.tintColor = layoutVars.buttonColor1
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.setProgress(imageData.uploadProgress!, animated: true)
        self.contentView.addSubview(self.progressView)
        
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        
        let viewsDictionary = ["pic":self.selectedImageView,"progressLbl":progressLbl,"reloadBtn":reloadBtn,"progressBar":progressView] as [String : Any]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[pic(50)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[progressBar(6)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[progressLbl(200)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[reloadBtn(80)]-|", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[reloadBtn(30)]", options: [], metrics: nil, views: viewsDictionary))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[pic(50)]-10-[progressBar]-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    @objc func handleReload(){
        self.progressLbl.text = "Uploading"
        self.reloadBtn.isHidden = true
        self.progressLbl.textColor = UIColor(hex: 0x005100, op: 1.0)
        self.progressView.progress = 0.0
        self.progressView.progressTintColor = UIColor(hex: 0x005100, op: 1.0)
        upload()
    }
    
    func upload(){
        print("cell start upload")
        
        var createdBy:String = ""
        
        if(self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) == "0"){
            createdBy = "0"
        }else{
            createdBy = (self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId))!
        }
        
                var parameters:[String:String]
                parameters = [
                    "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,
                    "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,
                    "name":imageData.name,
                    "desc":imageData.description,
                    "tags":"",
                    "customer":imageData.customer,
                    "createdBy":createdBy,
                    "leadTask":imageData.leadTaskID,
                    "contractTask":imageData.contractTaskID,
                    "task":imageData.taskID,
                    "woID":imageData.woID,
                    "equipmentID":imageData.equipmentID,
                    "albumID":imageData.albumID,
                    "usageID":imageData.usageID,
                    "vendorID":imageData.vendorID
                    ] as! [String : String]
                print("parameters = \(parameters)")
                
                let URL = try! URLRequest(url: self.saveURLString, method: .post, headers: nil)
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    print("alamofire upload")
                    for (key, value) in parameters {
                        multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                    }
                
                    if  let imageData = self.uiImage.fixedOrientation().jpegData(compressionQuality: 0.85) {
                        multipartFormData.append(imageData, withName: "pic", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                        
                    }
                    
                }, with: URL, encodingCompletion: { (result) in
                    
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (Progress) in
                            print("Upload Progress: \(Progress.fractionCompleted)")
                            
                            DispatchQueue.main.async() {
                                self.progressView.progress = Float(Progress.fractionCompleted)
                                    if  (Progress.fractionCompleted == 1.0) {
                                        print("upload finished")
                                        self.progressLbl.text = "Upload Complete"
                                    }
                                }
                        })
                        
                        upload.responseJSON { response in
                           // print(response.request ?? "")  // original URL request
                            print(response.response ?? "") // URL response
                            print(response.data ?? "")     // server data
                            print("result = \(response.result)")   // result of response serialization
                            
                            if("\(response.result)" == "FAILURE") {
                                self.layoutVars.playErrorSound()
                               self.progressLbl.text = "Failed"
                                self.reloadBtn.isHidden = false
                                self.progressLbl.textColor = UIColor.red
                                self.progressView.progressTintColor = UIColor.red
                            }
                            
                            if let result = response.result.value {
                                self.layoutVars.playSaveSound()
                                let json = result as! NSDictionary
                                
                                print("image json = \(json)")
                                let thumbBase = JSON(json)["thumbBase"].stringValue
                                let mediumBase = JSON(json)["mediumBase"].stringValue
                                let rawBase = JSON(json)["rawBase"].stringValue
                                let thumbPath = "\(thumbBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                                let mediumPath = "\(mediumBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                                let rawPath = "\(rawBase)\(JSON(json)["images"][0]["fileName"].stringValue)"
                                
                                let image = Image2(_id: JSON(json)["images"][0]["ID"].stringValue, _fileName: "", _name: JSON(json)["images"][0]["name"].stringValue, _width: JSON(json)["images"][0]["width"].stringValue, _height: JSON(json)["images"][0]["height"].stringValue, _description: JSON(json)["images"][0]["description"].stringValue, _dateAdded: JSON(json)["images"][0]["dateAdded"].stringValue, _createdBy: JSON(json)["images"][0]["createdBy"].stringValue, _type: JSON(json)["images"][0]["type"].stringValue)
                                
                                image.customer = JSON(json)["images"][0]["customer"].stringValue
                                image.custName = JSON(json)["images"][0]["custName"].stringValue
                                image.woID = JSON(json)["images"][0]["woID"].stringValue
                                image.tags = JSON(json)["images"][0]["tags"].stringValue
                                
                                image.thumbPath = thumbPath
                                image.mediumPath = mediumPath
                                image.rawPath = rawPath
                                
                                
                                self.scoreAdjust = JSON(json)["scoreAdjust"].intValue
                                
                                self.uploadDelegate.returnImage(_indexPath:self.indexPath ,_image: image, _scoreAdjust: self.scoreAdjust!)
                            }
                        }
                        upload.responseString { response in
                            print("RESPONSE: \(response)")
                        }
                    case .failure(let encodingError):
                        print("fail \(encodingError)")
                        self.progressLbl.text = "Failed"
                        self.reloadBtn.isHidden = false
                        self.progressLbl.textColor = UIColor.red
                        self.progressView.progressTintColor = UIColor.red
                        
                    }
                })
    }
}
