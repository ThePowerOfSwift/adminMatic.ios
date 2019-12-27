//
//  ImageUploadPrepViewController.swift
//  AdminMatic2
//
//  Created by Nick on 3/18/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

//this class is the user interface to be subclassed for gallery, field note, task and equipment image upload and edits

import Foundation
import UIKit
import Alamofire
import DKImagePickerController

 
protocol ImageUploadPrepDelegate {
    func scrollToCell(_indexPath:IndexPath)
    func updateDescription(_index:Int, _description:String)
    func uploadComplete(_images:[Image2],_scoreAdjust:Int)
}

protocol ImageDrawingDelegate{
    func updateImage(_indexPath:IndexPath, _image:UIImage)
}

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

protocol AttachmentDelegate{
    func updateTable(_points:Int)
    
}



class ImageUploadPrepViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate, ImageUploadPrepDelegate, ImageDrawingDelegate, ImageViewDelegate, NoInternetDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var delegate:ImageViewDelegate!  // refreshing the list
    var attachmentDelegate:AttachmentDelegate!  // refreshing the list
    var equipmentImageDelegate:UpdateEquipmentImageDelegate!
    var receiptImageDelegate:UpdateReceiptImageDelegate!
    var indicator: SDevIndicator!
    var backButton:UIBarButtonItem!
    
    let safeContainer:UIView = UIView()
    //header view
    var groupImages:Bool = false
    var groupSwitch:UISwitch = UISwitch()
    var groupSwitchLbl:Label = Label()
    var groupNameView:UIView = UIView()
    
    
    
    var groupNameTxt:PaddedTextField = PaddedTextField()
    var groupNamePlaceHolder:String!
    
    
    var groupDescriptionTxt: UITextView = UITextView()
    var groupDescriptionPlaceHolder:String!
    
    
    var groupSearchBar:UISearchBar = UISearchBar()
    var groupResultsTableView:TableView = TableView()
    var groupSearchResults:[String] = []
    
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView!
    
    
    var addImageBtn:Button = Button(titleText: "Add Image(s)")
    var changeImageBtn:Button = Button(titleText: "Change Image")
    var submitBtn:Button = Button(titleText: "Submit")
    
    var loadingView:UIView!
    
    var progressView:UIProgressView!
    var progressValue:Float!
    var progressLbl:Label!
    
    var keyBoardShown:Bool = false
    
    
    
    //linking result arrays
    var ids = [String]()
    var names = [String]()
    var allowImages = [String]()
    var selectedID:String = ""
    
    var allowIMGs:String = ""
    
    
   
    var woID:String = ""
    var woItemID:String = ""
    var attachmentID:String = ""
    var leadID:String = ""
    var leadTaskID:String = ""
    var taskID:String = ""
    var taskStatus:String = ""
    var albumID:String = ""
    var contractID:String = ""
    var contractItemID:String = ""
    var contractTaskID:String = ""
    
    
    var customerID:String = ""
    var customerName:String = ""
    
    var equipmentID:String = ""
    
    var usageID:String = ""
    var usageIndex:Int = 0
    var vendorID:String = ""
    
    //data items
    var imageType:String! //example: task, fieldnote, custImage, equipmentImage
    
    var images:[Image2] = [Image2]()  //full list of images being isplayed
   
    var uiImagesToSave:[UIImage] = [UIImage]()
    var linkType:String! //equipment link
    
    var imageAdded:Bool = false
    var textEdited:Bool = false
    
    var imageEdit:Bool = false
    var keyboardHeight:CGFloat = 216
    
    
    
    var tasks:[Task2] = []
    let taskCount:Int = 0
    
    var currentImageIndex:Int!
    var imageDetailViewController:ImageDetailViewController!
    
    var points:Int = 0
    
    var editsMade:Bool = false
    

    //init for attachments
    init(_imageType:String,_woID:String,_customerID:String,_attachmentID:String,_images:[Image2]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for attachments")
        self.imageType = _imageType
        self.attachmentID = _attachmentID
        self.woID = _woID
        self.customerID = _customerID
        self.images = _images
        
     
    }
    
    //init for tasks
    init(_imageType:String,_taskID:String,_customerID:String,_images:[Image2],_allowImages:String){
        
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for tasks")
        self.imageType = _imageType
        self.taskID = _taskID
        self.customerID = _customerID
        self.images = _images
        self.allowIMGs = _allowImages
       
        
        
    }
    
    //init for lead tasks
    init(_imageType:String,_leadID:String,_leadTaskID:String,_customerID:String,_images:[Image2],_allowImages:String){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for lead tasks")
        self.imageType = _imageType
        self.leadID = _leadID
        self.leadTaskID = _leadTaskID
        self.customerID = _customerID
        self.images = _images
        self.allowIMGs = _allowImages
       
        
       
        
        
    }
    
    
    //init for contract tasks
    init(_imageType:String,_contractItemID:String,_contractTaskID:String,_customerID:String,_images:[Image2],_allowImages:String){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for contract tasks")
        self.imageType = _imageType
        self.contractItemID = _contractItemID
        self.contractTaskID = _contractTaskID
        self.customerID = _customerID
        self.selectedID = _customerID
        self.images = _images
        self.allowIMGs = _allowImages
        
       
    }
    
    
    
    
    //init for customer
    init(_imageType:String,_customerID:String,_images:[Image2],_uiImages:[UIImage]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for customers")
        self.imageType = _imageType
        self.customerID = _customerID
        self.images = _images
        self.uiImagesToSave = _uiImages
        
        var i = 0
        for image in self.images{
            image.toBeSaved = "1"
            image.imageData = self.uiImagesToSave[i].jpegData(compressionQuality: 1.0)
            i += 1
        }
       
    }
    
    //init for gallery
    init(_imageType:String, _linkType:String = "",_images:[Image2],_uiImages:[UIImage]){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for gallery")
        self.imageType = _imageType
        self.linkType = _linkType
        self.images = _images
        self.uiImagesToSave = _uiImages
        var i = 0
        
        var methodStart:Date!
        var methodFinish:Date!
        
         methodStart = Date()
        
        for image in self.images{
            image.toBeSaved = "1"
                        
            image.imageData = self.uiImagesToSave[i].jpegData(compressionQuality: 1.0)
            i += 1
          
        }
        
        methodFinish = Date()
        let executionTime = methodFinish.timeIntervalSince(methodStart)
        print("Execution time: \(executionTime)")
        
    }
    
    //init for equipment
    init(_imageType:String, _equipmentID:String){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for equipment")
        self.imageType = _imageType
        self.equipmentID = _equipmentID
        var i = 0
        for image in self.images{
            image.toBeSaved = "1"
            image.imageData = self.uiImagesToSave[i].jpegData(compressionQuality: 1.0)
            i += 1
            
        }
        
    }
    
    //init for receipt
    init(_imageType:String, _usageID:String,_usageIndex:Int){
        super.init(nibName:nil,bundle:nil)
        print("ImageUploadPrep init for receipt")
        self.imageType = _imageType
        self.usageID = _usageID
        self.usageIndex = _usageIndex
        var i = 0
        for image in self.images{
            image.toBeSaved = "1"
            image.imageData = self.uiImagesToSave[i].jpegData(compressionQuality: 1.0)

            i += 1
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //print("ImageUploadPrep viewDidLoad imageType = \(self.imageType)")
        
       
        
        switch imageType {
        case "Gallery":
                title = "Upload to Gallery"
            break
        case "Customer":
                title = "Upload Customer Image"
            break
        case "Attachment":
                title = "Add/Update Attachment"
            break
        case "Task":
                title = "Add/Update Task"
            break
        case "Lead Task":
                title = "Add/Update Lead Task"
            break
        case "Contract Task":
            title = "Add/Update Contract Task"
            break
        case "Equipment":
            title = "Add Equipment Image"
            break
        case "Receipt":
            title = "Add Receipt Image"
            break
        
            
        case .none:
            print("bad switch case")
        case .some(_):
            print("bad switch case")
        }

        
        view.backgroundColor = UIColor.darkGray
        
        self.loadingView = UIView(frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: layoutVars.fullHeight))
        
        
        
        self.backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = self.backButton
    }
    

    func loadLinkList(){
        print("load link list")
        
        if CheckInternet.Connection() != true{
                          self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                          return
                      }
               
               
        
        
        // Show Indicator
        indicator = SDevIndicator.generate(self.view)!
    
        
        
        
        //Get customer list
               var parameters:[String:String]
                parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!]
               print("parameters = \(parameters)")
               
               self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/customers.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                   .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                   .responseString { response in
                       print("lead response = \(response)")
                   }
                   .responseJSON() {
                       response in
                       
            //print(response.request ?? "")  // original URL request
            //print(response.response ?? "") // URL response
            //print(response.data ?? "")     // server data
            //print(response.result)   // result of response serialization
            do {
                if let data = response.data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let results = json["customers"] as? [[String: Any]] {
                    for result in results {
                        if let id = result["ID"] as? String {
                            self.ids.append(id)
                        }
                        print("name = \(String(describing: result["name"]))")
                        if let name = result["name"] as? String {
                            self.names.append(name)
                        }
                        print("allowImages = \(String(describing: result["allowImages"]))")
                        if let allowImages = result["allowImages"] as? String {
                            self.allowImages.append(allowImages)
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            self.layoutViews()
        }
    }
    
    

    func layoutViews(){
        
        print("layoutViews")
        if(indicator != nil){
            indicator.dismissIndicator()
        }
        
         currentImageIndex = 0
        
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.groupNameView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        groupSwitch.removeTarget(self, action: #selector(ImageUploadPrepViewController.switchValueDidChange(sender:)), for: .valueChanged)
        groupSwitch.isHidden = true
        
        
        //set container to safe bounds of view
        
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50), collectionViewLayout: layout)
        self.imageCollectionView.delegate  =  self
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.register(ImageUploadPrepCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.imageCollectionView!)

        self.imageCollectionView.alwaysBounceVertical = true
        self.imageCollectionView.backgroundColor = UIColor.darkGray
        
        if imageType != "Equipment" && imageType != "Receipt"{
            self.groupNameView.backgroundColor = UIColor.lightGray
            self.groupNameView.translatesAutoresizingMaskIntoConstraints = false
            safeContainer.addSubview(self.groupNameView)
            groupSwitch.isOn = groupImages
            groupSwitch.translatesAutoresizingMaskIntoConstraints = false
            groupSwitch.addTarget(self, action: #selector(ImageUploadPrepViewController.switchValueDidChange(sender:)), for: .valueChanged)
            self.groupNameView.addSubview(groupSwitch)
        }
        
        
        
        
      
        
        if(self.imageType == "Gallery"){
            print("gallery")
            
            groupSwitchLbl.translatesAutoresizingMaskIntoConstraints = false
            self.groupNameView.addSubview(groupSwitchLbl)
            groupSwitchLbl.text = "Album"
            
           
        
            groupNamePlaceHolder = "Album Name..."
            
            if(groupImages == true){
                
                self.groupNameTxt.placeholder = groupNamePlaceHolder
                self.groupNameTxt.translatesAutoresizingMaskIntoConstraints = false
                self.groupNameTxt.delegate = self
                self.groupNameTxt.font = layoutVars.smallFont
                self.groupNameTxt.returnKeyType = UIReturnKeyType.done
                self.groupNameTxt.layer.cornerRadius = 4
                self.groupNameTxt.clipsToBounds = true
                self.groupNameTxt.backgroundColor = layoutVars.backgroundLight
                self.groupNameView.addSubview(self.groupNameTxt)
            }
            
            groupSearchBar.placeholder = "Customer..."
            groupSearchBar.translatesAutoresizingMaskIntoConstraints = false
            groupSearchBar.layer.cornerRadius = 4
            groupSearchBar.clipsToBounds = true
            groupSearchBar.backgroundColor = UIColor.white
            groupSearchBar.barTintColor = UIColor.clear
            groupSearchBar.searchBarStyle = UISearchBar.Style.minimal
            groupSearchBar.delegate = self
            self.groupNameView.addSubview(groupSearchBar)
            
            if(self.ids.count == 0){
                groupSearchBar.isUserInteractionEnabled = false
            }
            
            self.groupResultsTableView.delegate  =  self
            self.groupResultsTableView.dataSource = self
            //might want to change to custom linkCell class
            self.groupResultsTableView.register(CustomerTableViewCell.self, forCellReuseIdentifier: "linkCell")
            self.groupResultsTableView.alpha = 0.0
            safeContainer.addSubview(self.groupResultsTableView)
            
            
            
            self.addImageBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.addImages), for: UIControl.Event.touchUpInside)
            safeContainer.addSubview(self.addImageBtn)
            
            
            
          
                self.submitBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.pickImageUploadSize), for: UIControl.Event.touchUpInside)
            
            
            safeContainer.addSubview(self.submitBtn)
            
        }else if imageType == "Equipment"{
            print("Equipment or Receipt")
            
            
            
            self.changeImageBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.changeImage), for: UIControl.Event.touchUpInside)
            safeContainer.addSubview(self.changeImageBtn)
            
           
            
            
            
            self.submitBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.forceSmallUpload), for: UIControl.Event.touchUpInside)
            safeContainer.addSubview(self.submitBtn)
            print("end")
            
            
            
        }else{
            print("attachment / task / lead task / contract task / customer / Receipt")
            
                groupDescriptionPlaceHolder = "\(imageType!) description..."
            
            
                self.groupDescriptionTxt.text = groupDescriptionPlaceHolder
                self.groupDescriptionTxt.textColor = UIColor.lightGray
                
                self.groupDescriptionTxt.translatesAutoresizingMaskIntoConstraints = false
                self.groupDescriptionTxt.delegate = self
                self.groupDescriptionTxt.font = layoutVars.smallFont
                self.groupDescriptionTxt.returnKeyType = UIReturnKeyType.done
                self.groupDescriptionTxt.layer.cornerRadius = 4
                self.groupDescriptionTxt.clipsToBounds = true
                self.groupDescriptionTxt.backgroundColor = layoutVars.backgroundLight
                self.groupNameView.addSubview(self.groupDescriptionTxt)
                
                 print("group images")
            
            if(self.woID != "0" || self.taskID != "0" || self.leadTaskID != "0" || self.contractTaskID != "0"){
                self.groupDescriptionTxt.isEditable = true
            }else{
                self.groupDescriptionTxt.isEditable = false
            }
            
            self.addImageBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.addImages), for: UIControl.Event.touchUpInside)
            safeContainer.addSubview(self.addImageBtn)
            

            
            self.submitBtn.addTarget(self, action: #selector(ImageUploadPrepViewController.pickImageUploadSize), for: UIControl.Event.touchUpInside)
            safeContainer.addSubview(self.submitBtn)
            
           
            
            
            
             print("end")
            
        }
        
        
        
        
        //when to hide or show btns
        if(self.attachmentID == "0" || self.taskID == "0" || self.leadTaskID == "0" || self.imageType == "Customer" || self.imageType == "Gallery" || self.contractTaskID == "0"){
       
            print("new item")
            self.submitBtn.setTitle("Submit", for: UIControl.State())
        }else{
            print("existing item")
            self.submitBtn.setTitle("Update", for: UIControl.State())
            
        }
        
        
        
        
        setConstraints()
        
        
    }
    
    
    func setConstraints(){
        print("set constraints")
        
        let sizeVals = ["width": layoutVars.fullWidth - 30,"height": 40, "navBarHeight":layoutVars.navAndStatusBarHeight, "keyboardHeight":self.keyboardHeight] as [String : Any]
        
        
         if(self.imageType == "Gallery"){
            
            //auto layout group
            let viewsDictionary = [
                "groupNameView":self.groupNameView, "imageCollection":self.imageCollectionView, "searchTable":self.groupResultsTableView, "addImageBtn":self.addImageBtn, "submitBtn":self.submitBtn
                ] as [String:Any]
            
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[groupNameView]|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageCollection]-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchTable]-|", options: [], metrics: nil, views: viewsDictionary))
             safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addImageBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            
            if(groupImages == true){
                safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupNameView(90)]-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                
                
                
                safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupNameView(90)]-[searchTable]-keyboardHeight-|", options: [], metrics: sizeVals, views: viewsDictionary))
                
                
            }else{
                
                
                
                
                if(self.imageType != "Customer"){
                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupNameView(50)]-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                    
                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupNameView(50)]-[searchTable]-keyboardHeight-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }else{
                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                    
                }
               
            }
            
            let viewsDictionary2 = ["groupSwitch":self.groupSwitch, "groupSwitchLbl":self.groupSwitchLbl, "groupNameTxt":self.groupNameTxt,"searchBar":groupSearchBar] as [String:Any]
            
            
            if(groupImages == true){
                
                    groupSwitch.isHidden = false
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupSwitch(50)]-20-[groupSwitchLbl(70)]-10-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupNameTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitch(30)]-[groupNameTxt(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitchLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(30)]", options: [], metrics: nil, views: viewsDictionary2))
                
                
            }else{
                groupSwitch.isHidden = false
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupSwitch(40)]-10-[groupSwitchLbl(70)]-10-[searchBar]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitch(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupSwitchLbl(30)]", options: [], metrics: nil, views: viewsDictionary2))
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchBar(30)]", options: [], metrics: nil, views: viewsDictionary2))
            }
            
            
            
            
                
                
                
        }else if self.imageType == "Equipment" || self.imageType == "Receipt"{
            
            
            
            let viewsDictionary = [
                 "imageCollection":self.imageCollectionView, "changeImageBtn":self.changeImageBtn, "submitBtn":self.submitBtn
                ] as [String:Any]
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageCollection]-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[changeImageBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageCollection]-[changeImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
            
            
            
        }else{
            //field notes and tasks
            //auto layout group
            let viewsDictionary = [
                "groupNameView":self.groupNameView, "imageCollection":self.imageCollectionView, "addImageBtn":self.addImageBtn, "submitBtn":self.submitBtn
                ] as [String:Any]
            
            if(self.imageType != "Customer"){
                safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[groupNameView]|", options: [], metrics: nil, views: viewsDictionary))
            }
            
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageCollection]-|", options: [], metrics: nil, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[submitBtn]-|", options: [], metrics: nil, views: viewsDictionary))
             safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[addImageBtn]-|", options: [], metrics: nil, views: viewsDictionary))
            
            
            if(images.count > 0){
                if(self.imageType != "Customer"){
                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupNameView(90)]-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }else{
                     safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }
                
               
            }else{
                if(self.imageType != "Customer"){

                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupNameView(90)]", options: [], metrics: sizeVals, views: viewsDictionary))
                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-60-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                }else{
                    
                    
                    safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat:"V:|-20-[imageCollection]-[addImageBtn(40)]-[submitBtn(40)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
                    
                }
                
            }
            
        if(self.imageType != "Customer"){
            
            
            let viewsDictionary2 = ["groupDescriptionTxt":self.groupDescriptionTxt] as [String:Any]
            
            
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[groupDescriptionTxt]-|", options: [], metrics: nil, views: viewsDictionary2))
                
                self.groupNameView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[groupDescriptionTxt(70)]", options: [], metrics: nil, views: viewsDictionary2))
            }
        }
        
        
        
    }
    
    
    /////////////// CollectionView Delegate Methods   ///////////////////////
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(self.images.count > 0){
            let totalHeight: CGFloat = 310.0
            let totalWidth: CGFloat = (self.view.frame.width - 10)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }else{
            let totalHeight: CGFloat = 50.0
            let totalWidth: CGFloat = (self.view.frame.width - 10)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("making cells")
        
        print("images.count = \(self.images.count)")
        
        print("indexPath.row = \(indexPath.row)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageUploadPrepCollectionViewCell
        
        cell.backgroundColor = UIColor.lightGray
            cell.imageData = images[indexPath.row]
        
      
            cell.layoutViews()
            cell.delegate = self
            cell.indexPath = indexPath
            cell.setText()
        
        if imageType == "Receipt"{
            cell.descriptionTxt.isHidden = true
        }
        
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
            //print("show full image view")
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageUploadPrepCollectionViewCell
        
        if(self.images[indexPath.row].ID != "0" && self.images[indexPath.row].ID != ""){
            
            
            var type:String!
            var taskIDToDelete:String!
            
            switch imageType {
            case "Gallery":
                //title = "Upload to Gallery"
                self.viewImage(_indexPath:indexPath,_image:currentCell.imageData,_uiImage: currentCell.uiImage!)
                break
            case "Customer":
                //title = "Upload Customer Image"
                self.viewImage(_indexPath:indexPath,_image:currentCell.imageData,_uiImage: currentCell.uiImage!)
                break
            case "Attachment":
                //title = "Add/Update Attachment"
                self.viewImage(_indexPath:indexPath,_image:currentCell.imageData,_uiImage: currentCell.uiImage!)
                break
            case "Task":
                //title = "Add/Update Task"
                type = "3"
                taskIDToDelete = self.taskID
                break
            case "Lead Task":
                //title = "Add/Update Lead Task"
                type = "1"
                taskIDToDelete = self.leadTaskID
                break
            case "Contract Task":
                //title = "Add/Update Contract Task"
                type = "2"
                taskIDToDelete = self.contractTaskID
                break
            case "Equipment":
                //title = "Add Equipment Image"
                self.viewImage(_indexPath:indexPath,_image:currentCell.imageData,_uiImage: currentCell.uiImage!)
                break
            case "Receipt":
                //title = "Add Equipment Image"
                self.viewImage(_indexPath:indexPath,_image:currentCell.imageData,_uiImage: currentCell.uiImage!)
                break
                
                
            case .none:
                print("bad switch case")
            case .some(_):
                print("bad switch case")
            }
            
            
            
            let actionSheet = UIAlertController(title: "Image Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            
            actionSheet.addAction(UIAlertAction(title: "View Large Image", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                
                
                self.viewImage(_indexPath:indexPath,_image:currentCell.imageData,_uiImage: currentCell.uiImage!)
                
               
                
                return
                
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Delete Image Link", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                
                print("delete task image")
                
                
                self.deleteImage(_type: type, _taskID: taskIDToDelete, _imageID: currentCell.imageData.ID,_indexPath: indexPath)
                
            
            }))
            
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover:UIPopoverPresentationController = nav.popoverPresentationController! //as //UIPopoverPresentationController
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                self.present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
            
            
            
            
            
            
            
            
            return
            
           
        }
        
        
            
            
            
            let actionSheet = UIAlertController(title: "Edit Image Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Drawing", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                self.draw(_indexPath: indexPath, _image: UIImage(data: self.images[indexPath.row].imageData! as Data)!)
            }))
            
        
            
            actionSheet.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                self.close(_indexPath: indexPath)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)

                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController as UIPopoverPresentationController?
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                self.present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }

    }
    
    func viewImage(_indexPath:IndexPath,_image:Image2,_uiImage:UIImage){
        
        self.imageDetailViewController = ImageDetailViewController(_image: _image)
        self.imageCollectionView?.deselectItem(at: _indexPath, animated: true)
        self.navigationController?.pushViewController(self.imageDetailViewController, animated: false )
        self.imageDetailViewController.delegate = self
        
        self.currentImageIndex = _indexPath.row
        
        
        
    }
    
    func deleteImage(_type:String,_taskID:String,_imageID:String,_indexPath:IndexPath){
        
        
        if CheckInternet.Connection() != true{
                          self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                          return
                      }
               
               
        
        
        //need userLevel greater then 1 to access this
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            
            return
        }
        
        
        let alertController = UIAlertController(title: "Delete Image Link?", message: "Are you sure you want to delete the link to this image?", preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
            (result : UIAlertAction) -> Void in
            print("No")
            return
        }
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
            (result : UIAlertAction) -> Void in
            print("Yes")
            
            var parameters:[String:String]
            parameters = [
                "type":_type,"ID":_taskID,"imageID":_imageID
                
            ]
            
            print("parameters = \(parameters)")
            self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/delete/imageLink.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                print(response.result)   // result of response serialization
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    
                    self.images.remove(at: _indexPath.row)
                    self.imageCollectionView.reloadData()
                    
                    self.attachmentDelegate.updateTable(_points: 0)
                    //return
                }
                }.responseString { response in
                    //print("response = \(response)")
            }
            
            
        }
        
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
    }
    
    
    
    @objc func addImages(){
        print("add images")
        
        
        // if customer doesn't want image collection
        if self.allowIMGs == "0"{
                    layoutVars.simpleAlert(_vc: self, _title: "No Image Collection", _message: "This customer does not want images collected.")
                    return
                   }
        
        
        
        //print("imageType = \(self.imageType)")
        
        let n: Int! = self.navigationController?.viewControllers.count
        print("add images 2")
        switch (self.imageType) {
            
        case "Attachment":
            
            print("add images attachment")
            if(self.navigationController?.viewControllers[n-3] is ScheduleViewController){
                let myUIViewController = self.navigationController?.viewControllers[n-3] as! ScheduleViewController
                
                if(myUIViewController.searchController != nil){
                    myUIViewController.searchController.isActive = false
                }
            }
            break
            
        case "Task":
            
            print("add images task")
            if(self.navigationController?.viewControllers[n-4] is ScheduleViewController){
                print("add images task in if")
                let myUIViewController = self.navigationController?.viewControllers[n-4] as! ScheduleViewController
                
                if(myUIViewController.searchController != nil){
                    myUIViewController.searchController.isActive = false
                }
            }
            break
            
        case "Customer":
            let myUIViewController = self.navigationController?.viewControllers[n-3] as! CustomerListViewController
            
            if(myUIViewController.searchController != nil){
                myUIViewController.searchController.isActive = false
            }
            break
            
        case "Equipment":
            
            break
        
        case "Receipt":
            
            break
            
        default://home
            print("add images 3")
            break
            
        }
        
       
        
        
       let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        
        print("add images 4")
        
        
        multiPicker.showsCancelButton = true
       multiPicker.assetType = .allPhotos
        
        if(imageType == "Equipment" || imageType == "Receipt"){
            multiPicker.maxSelectableCount = 1
        }
        
        self.layoutVars.getTopController().present(multiPicker, animated: true) {}
        
       
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            // Show Indicator
            self.indicator = SDevIndicator.generate(self.view)!
            
            
            self.imageAdded = true
            
            for i in 0..<assets.count
            {
                print("looping images")
               
                
                
                assets[i].fetchOriginalImage(completeBlock: { image, info in
                    
                    
                    print("making image")
                    
                    var image = image
                    image = self.layoutVars.imageOrientation(image!)
                    
                    
                   
                    let imageToAdd:Image2 = Image2(_id: "0", _fileName: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)!, _type: "")
                    
                  
                    
                    if self.taskID != "" || self.leadTaskID != "" || self.contractTaskID != ""{
                        imageToAdd.description = self.groupDescriptionTxt.text!
                        imageToAdd.customer = self.customerID
                        imageToAdd.custName = self.customerName
                    }
                    
                    if self.usageID != ""{
                        imageToAdd.usageID = self.usageID
                    }
                    if self.vendorID != ""{
                        imageToAdd.vendorID = self.vendorID
                    }
                    
                    imageToAdd.toBeSaved = "1"
                     imageToAdd.imageData = image!.jpegData(compressionQuality: 1.0)

                    
                    self.uiImagesToSave.append(image!)
                    self.images.append(imageToAdd)
                    
                 
                    if i == assets.count - 1{
                        print("images count = \(self.images.count)")
                        
                        self.imageCollectionView.reloadData()
                        
                        
                        let lastItem = self.collectionView(self.imageCollectionView, numberOfItemsInSection: 0) - 1
                        let indexPath: NSIndexPath = NSIndexPath.init(item: lastItem, section: 0)
                        
                        self.imageCollectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
                        
                        self.indicator.dismissIndicator()
                    }
                    
                })
                
                
                
            }
            
            
            
            
        }
 
        
        
    }
    
    
    
    
    //change image function used for equipment where only one image can be uploaded
    @objc func changeImage(){
        print("change image")
        
        self.images = []
     
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        
        print("add images 4")
        
      
        
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        
       
        multiPicker.maxSelectableCount = 1
       
        
        self.layoutVars.getTopController().present(multiPicker, animated: true) {}
        
        
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            // Show Indicator
            self.indicator = SDevIndicator.generate(self.view)!
            
            
            self.imageAdded = true
            
            for i in 0..<assets.count
            {
                print("looping images")
               
                
                assets[i].fetchOriginalImage(completeBlock: { image, info in
                    
                    
                    print("making image")
                    
                    var image = image
                    image = self.layoutVars.imageOrientation(image!)
                    
                    
                    
                    let imageToAdd:Image2 = Image2(_id: "0", _fileName: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)!, _type: "")
                    
                    
                   
                    
                    imageToAdd.toBeSaved = "1"
                    
                    imageToAdd.imageData = image!.jpegData(compressionQuality: 1.0)
                    
                    
                    self.uiImagesToSave.append(image!)
                    self.images.append(imageToAdd)
                    
                    
                    
                    
                    if i == assets.count - 1{
                        print("images count = \(self.images.count)")
                        
                        self.imageCollectionView.reloadData()
                        
                       
                        
                        self.indicator.dismissIndicator()
                    }
                    
                })
                
                
                
            }
            
            
            
            
        }
 
        
    }
    
    
    
    
    
    
    
    

    
    func scrollToCell(_indexPath:IndexPath) {
        print("scroll to cell _indexPath = \(_indexPath.row)")
        
        
        
        
        let attributes:UICollectionViewLayoutAttributes = self.imageCollectionView.layoutAttributesForItem(at: _indexPath)!
        
        print("cell y location = \(attributes.frame.minY)")
        //scrolls to cell
        // print("currentScrollPosition = \(currentScrollPosition)")
        self.imageCollectionView.setContentOffset(CGPoint(x: 0, y: attributes.frame.midY), animated: true)
    }
    
    func uploadComplete(_images:[Image2],_scoreAdjust:Int){
        print("upload complete")

        if(self.imageType == "Gallery" || self.imageType == "Customer"){
            delegate.refreshImages(_images: _images)
            
            
            
        }else if(self.imageType == "Task" || self.imageType == "Lead Task" || self.imageType == "Contract Task"){
            attachmentDelegate.updateTable(_points: (_scoreAdjust + points))
        }else if self.imageType == "Equipment"{
            
            equipmentImageDelegate.updateImage(_image: _images[0])
        }else if self.imageType == "Receipt"{
            receiptImageDelegate.updateImage(_image: _images[0], _usageIndex:self.usageIndex)
            
            
        }else{//attachments
            attachmentDelegate.updateTable(_points: (_scoreAdjust + points))
        }
        
        
    }
    
    
    func updateDescription(_index:Int, _description:String){
        print("update description index: \(_index) _description: \(_description)")
        self.images[_index].description = _description
    }
    
    
     
    
    
    func getPrevNextImage(_next:Bool){
        //print("IN  getPrevNextImage currentImageIndex = \(currentImageIndex!)")
        
            if(_next == true){
                if(currentImageIndex + 1) > (self.images.count - 1){
                    currentImageIndex = 0
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    
                    
                    
                }else{
                    currentImageIndex = currentImageIndex + 1
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.images.count - 1
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    
                }else{
                    currentImageIndex = currentImageIndex - 1
                    imageDetailViewController.image = self.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                   
                }
            }
        
       
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: false)
        
        
    }
    
    
    func refreshImages(_images:[Image2]){
        print("refreshImages")
       
    }
    
    
    
    
   
    
    
    
/////////////// TableView Delegate Methods   ///////////////////////

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection")
            return self.groupSearchResults.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
            let cell = groupResultsTableView.dequeueReusableCell(withIdentifier: "linkCell") as! CustomerTableViewCell
            groupResultsTableView.rowHeight = 50.0
            cell.nameLbl.text = self.groupSearchResults[indexPath.row]
            cell.name = self.groupSearchResults[indexPath.row]
            
            if let i = self.names.index(of: cell.nameLbl.text!) {
                cell.id = self.ids[i]
                cell.allowImages = self.allowImages[i]
            } else {
                cell.id = ""
                cell.allowImages = ""
            }
            cell.iconView.image = nil
            return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let currentCell = tableView.cellForRow(at: indexPath) as! CustomerTableViewCell
        print("currentCell.allowImages = \(currentCell.allowImages)")
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.groupResultsTableView.alpha = 0.0
        groupSearchBar.resignFirstResponder()
        
        
        if currentCell.allowImages! == "0"{
            groupSearchBar.text = ""
            
            layoutVars.simpleAlert(_vc: self, _title: "No Image Collection", _message: "\(currentCell.name!) does not want images collected.")
            return
        }
            selectedID = currentCell.id
        print("select cust")
        if(imageType == "Gallery"){
                for image in images{
                    print("set image cust \(selectedID)")
                    image.customer = selectedID
                }
            }
            
            groupSearchBar.text = currentCell.name
    }
    

    
/////////////// Search Delegate Methods   ///////////////////////

    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Filter the data you have. For instance:
        print("search edit")
        print("searchText.count = \(searchText.count)")
        
        
        if (searchText.count == 0) {
        self.groupResultsTableView.alpha = 0.0
         }else{
        self.groupResultsTableView.alpha = 1.0
          }
        
        filterSearchResults()
    }
    

    
    func filterSearchResults(){
        groupSearchResults = []
        
        self.groupSearchResults = self.names.filter({( aCustomer: String ) -> Bool in
            return (aCustomer.lowercased().range(of: groupSearchBar.text!.lowercased()) != nil)            })
        self.groupResultsTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.groupResultsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.groupResultsTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
        // Hide the cancel button
        searchBar.showsCancelButton = false
        // You could also change the position, frame etc of the searchBar
        self.groupResultsTableView.alpha = 0.0
    }

    @objc func switchValueDidChange(sender:UISwitch!)
    {
        print("switchValueDidChange groupImages = \(groupImages)")
        
        if (sender.isOn == true){
            print("on")
            groupImages = true
        }
        else{
            print("off")
            groupImages = false
        }
        layoutViews()
    }
    

    @objc func forceSmallUpload(){
        
        print("forceSmallUpload")
        self.uiImagesToSave = []
        for image in self.images{
            if image.toBeSaved == "1"{
                var uiImage = UIImage(data: image.imageData!)
                uiImage = uiImage!.resized(withPercentage: 0.5)!
                self.uiImagesToSave.append(uiImage!)
            }
        }
        self.saveData()
    }
    
    
    @objc func pickImageUploadSize(){
        
        if(uiImagesToSave.count == 0){
            if imageType == "Equipment"{
                self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Images Picked", _message: "")
            }else{
                self.saveData()
                return
            }
         }
 
        
        
        
        //check if there are any new images to save
        var imagesToSaveCount = 0
        
        for image in images{
            if image.toBeSaved == "1"{
                imagesToSaveCount += 1
            }
        }
        
        if imagesToSaveCount == 0{
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "No Images Picked", _message: "")
            
        }else{
            let actionSheet = UIAlertController(title: "Pick an Image Size", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            
            actionSheet.addAction(UIAlertAction(title: "Full 100%", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                  //print("show cam 1")
                self.uiImagesToSave = []
                for image in self.images{
                    if image.toBeSaved == "1"{
                        let uiImage = UIImage(data: image.imageData!)
                        self.uiImagesToSave.append(uiImage!)
                    }
                }
                
                
                self.saveData()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Medium 75%", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
               self.uiImagesToSave = []
                for image in self.images{
                    if image.toBeSaved == "1"{
                        var uiImage = UIImage(data: image.imageData!)
                        uiImage = uiImage!.resized(withPercentage: 0.75)!
                        self.uiImagesToSave.append(uiImage!)
                    }
                }
                
               
                self.saveData()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Small 50%", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                self.uiImagesToSave = []
                for image in self.images{
                    if image.toBeSaved == "1"{
                        var uiImage = UIImage(data: image.imageData!)
                        uiImage = uiImage!.resized(withPercentage: 0.5)!
                        self.uiImagesToSave.append(uiImage!)
                    }
                }
                
               
                
                self.saveData()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                //self.present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController!
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                //self.present(nav, animated: true, completion: nil)
                self.layoutVars.getTopController().present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                //self.present(actionSheet, animated: true, completion: nil)
                self.layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
            
        }
    }
    
    
    func saveData(){
        print("Save Data")
        
        if CheckInternet.Connection() != true{
                          self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                          return
                      }
               
               
        
        var imagesAdded:[Image2] = []
        
        if self.imageType != "Equipment"{
            for image in images{
                image.name = "\(self.imageType!) Image"
            }
        }else{
            for image in images{
                image.name = self.imageType!
            }
        }
        
        print("looping to check to be saved")
        var imagesToSaveCount = 0
        for image in self.images{
            print("image.toBeSaved = \(String(describing: image.toBeSaved))")
            if image.toBeSaved == "1"{
                imagesAdded.append(image)
                 imagesToSaveCount += 1
            }
        }
        
        
        
       
        
        
        if(self.imageType == "Gallery"){
        print("Gallery")
        
            if(groupImages == true){
                
                print("grouped")
                var groupNameString:String
                
                if(self.groupNameTxt.text == groupNamePlaceHolder){
                    groupNameString = ""
                }else{
                    groupNameString = self.groupNameTxt.text!
                    
                }
               
                let parameters:[String:String]
                parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"name": groupNameString,"description": "","createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)] as! [String:String]
                
                layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/new/album.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new album response = \(response)")
                }
                
                .responseJSON(){
                    response in
                    
                    print(response.request ?? "")  // original URL request
                    print(response.response ?? "") // URL response
                    print(response.data ?? "")     // server data
                    print(response.result)   // result of response serialization
                    
                    
                    
                    
                    //native way
                    
                    do {
                        if let data = response.data,
                            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            
                            
                            
                            
                            let albumID = json["newID"] as? String{
                            
                            print("albumID = \(albumID)")
                            for image in self.images{
                                image.albumID = albumID
                                image.customer = self.selectedID
                            }
                            
                           
                            let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                            imageUploadProgressViewController.uploadPrepDelegate = self
                            self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                            
                            
                        }
                        
                    } catch {
                        print("Error deserializing JSON: \(error)")
                    }
                    
                    
                    self.indicator.dismissIndicator()
                    
                }
                
                /*
                 print("groupImages = \(groupImages)")
                 print("ID = \(ID)")
                 print("groupDescriptionString = \(groupDescriptionString)")
                 print("selectedID = \(selectedID)")
                 print("woID = \(woID)")
                 print("images.count = \(images.count)")
                 print("saveURLString = \(saveURLString)")
                 */
                
               
            }else{
                //seperate images, no album
                print("seperate")
                
               
                
               // print("imagesadded.count = \(imagesAdded.count)")
                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                imageUploadProgressViewController.uploadPrepDelegate = self
                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                
                
            }
            
        }else{
            //tasks, lead tasks, wo attachments and customer
            print("tasks, lead tasks, contract tasks, wo attachments, equipment, receipts and customer")
            
            
            
                print("grouped")
                var groupDescString:String
                
                if(self.groupDescriptionTxt.text == groupDescriptionPlaceHolder){
                    groupDescString = ""
                    
                    
                    
                    
                    
                    if(imagesToSaveCount == 0){
                        let alertController = UIAlertController(title: "Add Text or Image", message: "Write a description or add an image to submit.", preferredStyle: UIAlertController.Style.alert)
                       
                        
                        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                            (result : UIAlertAction) -> Void in
                            print("OK")
                        }
                        
                        alertController.addAction(okAction)
                        self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                }else{
                    groupDescString = self.groupDescriptionTxt.text
                    
                }
            
              
            if(self.imageType == "Attachment"){
                
               
                
                var parameters = [String : Any]()
                if(self.attachmentID == "0"){
                    //new leadTask needs to create leadTask ID first
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"ID":"0", "note": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "custID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"0" as AnyObject] as [String : Any]
                }else{
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"ID":self.attachmentID, "note": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "custID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"0" as AnyObject] as [String : Any]
                }
                
                
                
                print("parameters = \(parameters)")
                
                layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/fieldNote.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new field note response = \(response)")
                    }
                    
                    .responseJSON(){
                        response in
                        
                        
                        //native way
                        
                        do {
                            if let data = response.data,
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                
                                
                                
                                let attachmentID = json["newID"] as? String{
                                
                                
                                print("attachmentID = \(String(describing: attachmentID))")
                                
                                
                                for image in imagesAdded{
                                    image.leadTaskID = attachmentID
                                    image.customer = self.selectedID
                                    image.woID = self.woID
                                }
                                
                              
                            }
                            
                            if(self.uiImagesToSave.count > 0){
                                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                                imageUploadProgressViewController.uploadPrepDelegate = self
                                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                            }else{
                                if((self.attachmentDelegate) != nil){
                                    self.attachmentDelegate.updateTable(_points: self.points)
                                }
                                self.imageAdded = false
                                self.textEdited = false
                                self.goBack()
                                
                            }
                            
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
                        
                       
                        
                }
            }else if(self.imageType == "Task"){
                //tasks
                print("tasks")
                var parameters = [String : Any]()
                if(self.taskID == "0"){
                    //new leadTask needs to create leadTask ID first
                     parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"ID":"0", "task": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "woItemID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":"1" as AnyObject] as [String : Any]
                }else{
                    //parameters = ["taskID":self.leadTaskID, "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                     parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"ID":self.taskID, "task": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject, "woItemID":self.selectedID as AnyObject, "woID":self.woID as AnyObject, "status":self.taskStatus as AnyObject] as [String : Any]
                }
                
            
                print("parameters = \(parameters)")
                layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/task.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new task response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        
                        //native way
                        
                        do {
                            if let data = response.data,
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            
                                let taskID = json["newID"] as? String{
                            
                                print("taskID = \(String(describing: taskID))")
                                for image in imagesAdded{
                                    image.taskID = taskID
                                    image.customer = self.customerID
                                    image.woID = self.woID
                                }
                            }
                            
                            if(self.uiImagesToSave.count > 0){
                                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                                imageUploadProgressViewController.uploadPrepDelegate = self
                                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                            }else{
                                if((self.attachmentDelegate) != nil){
                                    self.attachmentDelegate.updateTable(_points: self.points)
                                }
                                self.imageAdded = false
                                self.textEdited = false
                                self.goBack()
                            }
                            
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
                        
                }
            }else if(self.imageType == "Lead Task"){
                //Lead Task
                var parameters = [String : Any]()
               
                 if(self.leadTaskID == "0"){
                    //new leadTask needs to create leadTask ID first
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"taskID":"0", "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                }else{
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"taskID":self.leadTaskID, "leadID":self.leadID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                }
 
                    print("parameters = \(parameters)")
                layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/leadTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                        .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                        .responseString { response in
                            print("new task response = \(response)")
                        }
                        
                        .responseJSON(){
                            response in
                            
                            
                            //native way
                            
                            do {
                                if let data = response.data,
                                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],

                                    let newLeadTaskID = json["leadTaskID"] as? String{
                                    // print("taskID = \(String(describing: taskID) ?? default value)")
                                    for image in imagesAdded{
                                        image.leadTaskID = newLeadTaskID
                                        image.customer = self.customerID
                                    }
                                }
                                
                                if(self.uiImagesToSave.count > 0){
                                    let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                                    imageUploadProgressViewController.uploadPrepDelegate = self
                                    self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                                }else{
                                    if((self.attachmentDelegate) != nil){
                                        self.attachmentDelegate.updateTable(_points: self.points)
                                    }
                                    self.imageAdded = false
                                    self.textEdited = false
                                    self.goBack()
                                }
                            } catch {
                                print("Error deserializing JSON: \(error)")
                            }
                    }
            }else if(self.imageType == "Contract Task"){
                //Contract Task
                
                print("Contract Task Upload")
                var parameters = [String : Any]()
                
                if(self.contractTaskID == "0"){
                    //new leadTask needs to create leadTask ID first
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"taskID":"0", "contractItemID":self.contractItemID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                }else{
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"taskID":self.contractTaskID, "contractItemID":self.contractItemID, "taskDescription": groupDescString as AnyObject,"createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) as AnyObject]
                }
                
                print("parameters = \(parameters)")
                layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/contractTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        print("new task response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        //native way
                        
                        do {
                            if let data = response.data,
                                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                let newContractTaskID = json["taskID"] as? String{
                                // print("taskID = \(String(describing: taskID) ?? default value)")
                                for image in imagesAdded{
                                    image.contractTaskID = newContractTaskID
                                    image.customer = self.customerID
                                }
                            }
                            if(self.uiImagesToSave.count > 0){
                                let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                                imageUploadProgressViewController.uploadPrepDelegate = self
                                self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                            }else{
                                if((self.attachmentDelegate) != nil){
                                    self.attachmentDelegate.updateTable(_points: self.points)
                                }
                                self.imageAdded = false
                                self.textEdited = false
                                self.goBack()
                            }
                        } catch {
                            print("Error deserializing JSON: \(error)")
                        }
                }
                
            }else if(self.imageType == "Equipment"){
                
                print("save for equipment")
                for image in imagesAdded{
                   
                    image.equipmentID = self.equipmentID
                }
                 print("imagesAdded.count = \(imagesAdded.count)")
                print("uiImagesToSave.count = \(uiImagesToSave.count)")
                
                if(self.uiImagesToSave.count > 0){
                    let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                    imageUploadProgressViewController.uploadPrepDelegate = self
                    self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                }else{
                    
                    self.imageAdded = false
                    self.textEdited = false
                    self.goBack()
                }
            
            }else{
                //Customer
                
                if(groupImages == true){
                    
                    print("grouped")
                    var groupNameString:String
                    
                    if(self.groupNameTxt.text == groupNamePlaceHolder){
                        groupNameString = ""
                    }else{
                        groupNameString = self.groupNameTxt.text!
                        
                    }
                    let parameters:[String:String]
                    parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"name": groupNameString,"description": "","createdBy": self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)] as! [String:String]
                    
                    layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/new/album.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                        .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                        .responseString { response in
                            print("new album response = \(response)")
                        }
                        
                        .responseJSON(){
                            response in
                            
                            print(response.request ?? "")  // original URL request
                            print(response.response ?? "") // URL response
                            print(response.data ?? "")     // server data
                            print(response.result)   // result of response serialization
                            
                            //native way
                            
                            do {
                                if let data = response.data,
                                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                                  
                                    let albumID = json["newID"] as? String{
                                    
                                    print("albumID = \(albumID)")
                                    for image in imagesAdded{
                                        image.albumID = albumID
                                        image.customer = self.customerID
                                    }
                                    
                                    let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                                    imageUploadProgressViewController.uploadPrepDelegate = self
                                    self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                                    
                                }
                                
                            } catch {
                                print("Error deserializing JSON: \(error)")
                            }
                            
                            self.indicator.dismissIndicator()
                    }
                    
                }else{
                    //seperate images, no album
                    print("seperate")
                    
                    for image in imagesAdded{
                        image.customer = self.customerID
                    }
                    let imageUploadProgressViewController:ImageUploadProgressViewController = ImageUploadProgressViewController(_imageType: self.imageType, _images: imagesAdded, _uiImages: self.uiImagesToSave)
                    imageUploadProgressViewController.uploadPrepDelegate = self
                    self.navigationController?.pushViewController(imageUploadProgressViewController, animated: false )
                }
        }
            
            if(self.indicator != nil){
                self.indicator.dismissIndicator()
            }
            
            }
    }
    
    func showProgressScreen(){
        print("showProgressScreen")
        self.view.isUserInteractionEnabled = false
        self.submitBtn.isUserInteractionEnabled = false
        //self.backButton.isUserInteractionEnabled = false
        self.backButton.isEnabled = false
        self.progressView.alpha = 1.0
        UIView.animate(withDuration: 0.75, animations: {() -> Void in
            self.loadingView.alpha = 1
        })
    }
    
    func hideProgressScreen(){
        print("hideProgressScreen")
        UIView.animate(withDuration: 0.5,  animations: {
            self.progressView.alpha = 0.0
        }, completion: {(finished:Bool) in
            self.goBack()
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            groupDescriptionTxt.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.groupDescriptionTxt.textColor == UIColor.lightGray {
            self.groupDescriptionTxt.text = nil
            self.groupDescriptionTxt.textColor = UIColor.black
            self.textEdited = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.groupDescriptionTxt.text.isEmpty {
            self.groupDescriptionTxt.text = groupDescriptionPlaceHolder
            self.groupDescriptionTxt.textColor = UIColor.lightGray
            self.textEdited = false
        }else{
            
            if images.count > 0{
                let alertController = UIAlertController(title: "Update Image Captions", message: "", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    //loop through images and add captions
                    for image in self.images{
                        image.description = self.groupDescriptionTxt.text
                    }
                    self.imageCollectionView.reloadData()
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        self.view.endEditing(true)
        return false
    }
    
    func draw(_indexPath:IndexPath,_image:UIImage){
        let imageDrawingViewController = ImageDrawingViewController(_indexPath:_indexPath, _image:_image)
        imageDrawingViewController.delegate = self
        navigationController?.pushViewController(imageDrawingViewController, animated: false )
        imageEdit = true;
    }
    
    /*
    func crop(_indexPath:IndexPath,_image:UIImage){
        let imageCroppingViewController = ImageCroppingViewController(_indexPath:_indexPath, _image:_image)
        imageCroppingViewController.delegate = self
        navigationController?.pushViewController(imageCroppingViewController, animated: false )
        imageEdit = true;
    }
    */
    
    func close(_indexPath:IndexPath){
        if(images.count > 1){
            images.remove(at: _indexPath.row)
            self.imageCollectionView.reloadData()
        }else{
            if(self.imageType == "Gallery"){
                let alertController = UIAlertController(title: "Cancel Upload?", message: "", preferredStyle: UIAlertController.Style.alert)
                let yesAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    print("Yes")
                    self.goBack()
                }
                let noAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("No")
                }
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }else{
                images.remove(at: _indexPath.row)
                self.imageCollectionView.reloadData()
            }
        }
    }
    func updateImage(_indexPath:IndexPath, _image: UIImage) {
        print("updateImage")
        self.uiImagesToSave[_indexPath.row] = _image
        self.images[_indexPath.row].imageData = _image.jpegData(compressionQuality: 1.0)
        self.imageCollectionView.reloadData()
    }
    
    @objc func goBack(){
        print("go back")
        if(self.imageAdded == true || self.textEdited == true){
            let alertController = UIAlertController(title: "Go back without Submitting?", message: "", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                _ = self.navigationController?.popViewController(animated: false)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
    }
    
    func showCustomerImages(_customer:String){
        print("show customer images cust: \(_customer)")
    }
    
    func didSelect(image: UIImage?){
        print("did select image")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
       }
    
}
