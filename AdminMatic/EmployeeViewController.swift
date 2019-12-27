//
//  EmployeeViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/2/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView


import Foundation
import UIKit
import Alamofire
import MessageUI

class EmployeeViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MFMessageComposeViewControllerDelegate, ImageViewDelegate, ImageLikeDelegate, NoInternetDelegate  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    var employee:Employee2!
       
    var optionsButton:UIBarButtonItem!
    var tapBtn:UIButton!
    
    //employee info
    var employeeImage:UIImageView!
    var activityView:UIActivityIndicatorView!

    var employeeLbl:GreyLabel!
    var employeePhoneBtn:UIButton!
    var phoneNumberClean:String!
    
    var email: String = "No Email Found"
    var emailName: String = ""
    
    var emailBtn:Button!
    
    var deptCrewBtn:Button!
    var usageBtn:Button!
    var shiftsBtn:Button!
    var payrollBtn:Button!
    
    var licensesBtn:Button!
    var trainingBtn:Button!
    
    
    //employee images
    var totalImages:Int!
    var imageArray:[Image2] = []
    
    var noImagesLbl:Label = Label()
    
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    
    var currentImageIndex:Int = 0
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    
    var order:String = "ID DESC"
    
    
    var lazyLoad = 0
    var limit = 100
    var offset = 0
    var batch = 0
    
   
    
    var logOutBtn:Button!
    
    
    var keyBoardShown:Bool = false

   
    var deptCrewListViewController:DeptCrewListViewController!
    var shiftsViewController:ShiftsViewController!
    var payrollEntryViewController:PayrollEntryViewController!
    var usageViewController:UsageViewController!
    var licenseViewController:LicenseViewController!
    
    
    
    
    init(_employee:Employee2){
        super.init(nibName:nil,bundle:nil)
       // print("init _employeeID = \(_employee.ID)")
        self.employee = _employee
        
       // print("emp view init ID = \(self.employee.ID)")
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.indicator = SDevIndicator.generate(self.view)!
        
        getEmployeeData(_id:self.employee.ID)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        //print("view will appear")
        

        
        
        view.backgroundColor = layoutVars.backgroundColor
        title = "Employee"
        
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(EmployeeViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
       
    }
    
    func getEmployeeData(_id:String){
        
        print("getEmployeeData with \(_id)")
        //cache buster
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
       
        
        
        
        let parameters:[String:String]
        parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"empID":  _id ]
               
               
               
               print("parameters = \(parameters)")
               
               layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/employees.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                   .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                   .responseString { response in
                       print("response = \(response)")
                   }
                   .responseJSON(){
                       response in
            
            do{
                //created the json decoder
                let json = response.data
                let decoder = JSONDecoder()
                let parsedData = try decoder.decode(EmployeeArray.self, from: json!)
                print("parsedData = \(parsedData)")
                let employees = parsedData
               
                
                self.employee = employees.employees[0]
                
                self.indicator.dismissIndicator()
                
                self.getImages()
                
               
            }catch let err{
                print(err)
            }

            
            
            
          
        }
    }
    
    
   
    
    
    func getImages(){
        //print("get images")
        
        let parameters:[String:String]
        parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,"loginID": "\(String(describing: self.appDelegate.loggedInEmployee!.ID))","limit": "\(self.limit)","offset": "\(self.offset)", "order":self.order,"uploadedBy": self.employee.ID]
        
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
               // print("images response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                do{
                    //created the json decoder
                    let json = response.data
                    let decoder = JSONDecoder()
                    let parsedData = try decoder.decode(ImageArray.self, from: json!)
                    print("parsedData = \(parsedData)")
                    let images = parsedData
                    let imageCount = images.images.count
                    print("image count = \(imageCount)")
                    for i in 0 ..< imageCount {
                        //create an object
                        print("create a image object \(i)")
                        
                        images.images[i].index = i
                        images.images[i].setImagePaths(_thumbBase:images.thumbBase!,_mediumBase:images.mediumBase!,_rawBase:images.rawBase!)
                        self.imageArray.append(images.images[i])
                        
                    }
                    
                    if(self.lazyLoad == 0){
                        self.layoutViews()
                    }else{
                        self.lazyLoad = 0
                        self.imageCollectionView?.reloadData()
                    }
                    
                    if self.imageArray.count == 0{
                        self.noImagesLbl.isHidden = false
                    }else{
                        self.noImagesLbl.isHidden = true
                    }
                    
                    
                    
                    self.indicator.dismissIndicator()
                    //self.layoutViews()
                }catch let err{
                    print(err)
                }
                
        }
    }
    
    func layoutViews(){
        
        //self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.indicator.dismissIndicator()
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        //only show option button to profile of logged in user
        if self.employee.ID == appDelegate.loggedInEmployee?.ID{
            optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(EmployeeViewController.displayEmployeeOptions))
            navigationItem.rightBarButtonItem = optionsButton
        }
        
        
        //print("layoutViews")
       
        self.employeeImage = UIImageView()
        
       
        activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.translatesAutoresizingMaskIntoConstraints = false
        employeeImage.addSubview(activityView)
        activityView.startAnimating()
        
        
        
        print("image downloaded: https://adminmatic.com\(self.employee.pic!)")
        Alamofire.request("https://adminmatic.com"+self.employee.pic!).responseImage { response in
           // debugPrint(response)
            
            //print(response.request)
            //print(response.response)
           // debugPrint(response.result)
            
            if let image = response.result.value {
               //print("image downloaded: \(image)")
                
                
                self.employeeImage.image = image
                
                let image2 = Image2(_id: "", _fileName: "", _name: "", _width:"", _height: "", _description: "", _dateAdded: "", _createdBy: "", _type: "")
                image2.mediumPath = "https://adminmatic.com/uploads/general/medium/"+self.employee.pic!
                
                self.imageDetailViewController = ImageDetailViewController(_image: image2)
                self.activityView.stopAnimating()
            }
        }
        
        self.tapBtn = Button()
        self.tapBtn.translatesAutoresizingMaskIntoConstraints = false
        self.tapBtn.addTarget(self, action: #selector(EmployeeViewController.showImage), for: UIControl.Event.touchUpInside)
        self.tapBtn.backgroundColor = UIColor.clear
        self.tapBtn.setTitle("", for: UIControl.State.normal)
        safeContainer.addSubview(self.tapBtn)
        
        self.employeeImage.layer.cornerRadius = 5.0
        self.employeeImage.layer.borderWidth = 2
        self.employeeImage.layer.borderColor = layoutVars.borderColor
        self.employeeImage.clipsToBounds = true
        self.employeeImage.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.employeeImage)
        
        //name
        self.employeeLbl = GreyLabel()
        self.employeeLbl.text = self.employee.name
        self.employeeLbl.font = layoutVars.labelFont
        safeContainer.addSubview(self.employeeLbl)
        
        //phone
        self.phoneNumberClean = cleanPhoneNumber(self.employee.phone)
        
        self.employeePhoneBtn = Button()
        self.employeePhoneBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.employeePhoneBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 36.0, bottom: 0.0, right: 0.0)
        
        
        self.employeePhoneBtn.setTitle(testFormat(sourcePhoneNumber: self.employee.phone!), for: UIControl.State.normal)
        self.employeePhoneBtn.addTarget(self, action: #selector(EmployeeViewController.handlePhone), for: UIControl.Event.touchUpInside)
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.frame = CGRect(x: -35, y: -4, width: 28, height: 28)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.employeePhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        safeContainer.addSubview(self.employeePhoneBtn)

        self.emailBtn = Button()
        self.emailBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.emailBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 36.0, bottom: 0.0, right: 0.0)
        
        
        self.emailBtn.setTitle(self.email, for: UIControl.State.normal)
        if self.email != "No Email Found" {
            self.emailBtn.addTarget(self, action: #selector(CustomerViewController.emailHandler), for: UIControl.Event.touchUpInside)
        }
        
        let emailIcon:UIImageView = UIImageView()
        emailIcon.backgroundColor = UIColor.clear
        emailIcon.contentMode = .scaleAspectFill
        emailIcon.frame = CGRect(x: -35, y: -4, width: 28, height: 28)
        let emailImg = UIImage(named:"emailIcon.png")
        emailIcon.image = emailImg
        self.emailBtn.titleLabel?.addSubview(emailIcon)
        
        
        safeContainer.addSubview(self.emailBtn)
       
        
        self.deptCrewBtn = Button()
        self.deptCrewBtn.setTitle("Depts/Crews", for: UIControl.State.normal)
        self.deptCrewBtn.addTarget(self, action: #selector(self.showDepartments), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.deptCrewBtn)
        
        self.usageBtn = Button()
        self.usageBtn.setTitle("Usage", for: UIControl.State.normal)
        self.usageBtn.addTarget(self, action: #selector(self.showUsage), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.usageBtn)
        
        
        
        self.shiftsBtn = Button()
        self.shiftsBtn.setTitle("Shifts", for: UIControl.State.normal)
        self.shiftsBtn.addTarget(self, action: #selector(self.showShifts), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.shiftsBtn)
        
        self.payrollBtn = Button()
        self.payrollBtn.setTitle("Payroll", for: UIControl.State.normal)
        self.payrollBtn.addTarget(self, action: #selector(self.showPayroll), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.payrollBtn)
        
        self.licensesBtn = Button()
        self.licensesBtn.setTitle("Licenses", for: UIControl.State.normal)
        self.licensesBtn.addTarget(self, action: #selector(self.showLicenses), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.licensesBtn)
        
        self.trainingBtn = Button()
        self.trainingBtn.setTitle("Training", for: UIControl.State.normal)
        self.trainingBtn.addTarget(self, action: #selector(self.showTraining), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.trainingBtn)
        
        
        
        //Images
        imageCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50), collectionViewLayout: layout)
        imageCollectionView?.layer.cornerRadius = 4.0
        
        self.imageCollectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        safeContainer.addSubview(imageCollectionView!)
        
        self.edgesForExtendedLayout = UIRectEdge.top
        
        self.noImagesLbl.text = "No Images Uploaded"
        self.noImagesLbl.textColor = UIColor.white
        self.noImagesLbl.textAlignment = .center
        self.noImagesLbl.font = layoutVars.largeFont
        safeContainer.addSubview(self.noImagesLbl)
        
        
        self.logOutBtn = Button()
        
        if(appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) == self.employee.ID){
            self.logOutBtn.isHidden = false
            self.logOutBtn.setTitle("Log Out (\(self.employee.fName))", for: UIControl.State.normal)
            self.logOutBtn.addTarget(self, action: #selector(self.logout), for: UIControl.Event.touchUpInside)
            
        }else{
            self.logOutBtn.isHidden = true
        }
        safeContainer.addSubview(self.logOutBtn)
        
        
        //print("1")
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let viewsDictionary = [
            "image":self.employeeImage,
            "activity":self.activityView,
            "tapBtn":self.tapBtn,
            "name":self.employeeLbl,
            "phone":self.employeePhoneBtn,
            "email":self.emailBtn,
            "deptsCrewsBtn":self.deptCrewBtn,
            "usageBtn":self.usageBtn,
            "shiftsBtn":self.shiftsBtn,
            "payrollBtn":self.payrollBtn,
            "licensesBtn":self.licensesBtn,
            "trainingBtn":self.trainingBtn,
            "imageCollection":self.imageCollectionView!,
            "noImagesLbl":self.noImagesLbl,
            
            "logOutBtn":logOutBtn
            
            ] as [String:Any]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[name]-10-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[tapBtn(100)]", options: [], metrics: nil, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[activity(100)]", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[phone]-10-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[image(100)]-10-[email]-10-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[deptsCrewsBtn(halfWidth)]-5-[usageBtn]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[shiftsBtn(halfWidth)]-5-[payrollBtn]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[licensesBtn(halfWidth)]-5-[trainingBtn]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[imageCollection]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[noImagesLbl]-10-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[logOutBtn]-10-|", options: [], metrics: nil, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[image(100)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tapBtn(100)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[activity(100)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        if(appDelegate.defaults.string(forKey: loggedInKeys.loggedInId) == self.employee.ID){
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)][phone(30)]-10-[email(30)]-[deptsCrewsBtn(30)]-[shiftsBtn(30)]-[licensesBtn(30)]-[imageCollection]-[logOutBtn(40)]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)][phone(30)]-10-[email(30)]-[usageBtn(30)]-[payrollBtn(30)]-[trainingBtn(30)]-[imageCollection]-[logOutBtn(40)]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            
        }else{
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)][phone(30)]-10-[email(30)]-[deptsCrewsBtn(30)]-[shiftsBtn(30)]-[licensesBtn(30)]-[imageCollection]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
            safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)][phone(30)]-10-[email(30)]-[usageBtn(30)]-[payrollBtn(30)]-[trainingBtn(30)]-[imageCollection]-16-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        }
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[name(30)][phone(30)]-10-[email(30)]-[usageBtn(30)]-[payrollBtn(30)]-[trainingBtn(30)]-20-[noImagesLbl(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
    }
    
    
    @objc func displayEmployeeOptions(){
        //print("display Options")
        
        
        let actionSheet = UIAlertController(title: "Employee Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.view.backgroundColor = UIColor.white
        actionSheet.view.layer.cornerRadius = 5;
        
        actionSheet.addAction(UIAlertAction(title: "Change Password", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            //print("display Change Password View")
            
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Upload Signature", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            //print("Show Signature View")
            
            let signatureViewController:SignatureViewController = SignatureViewController(_employee: self.employee)
            self.navigationController?.pushViewController(signatureViewController, animated: false )
            
            
           
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Send Recruit Text", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
            //print("Send Recruit Text")
            
            self.sendRecruitmentText()
        
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
    
    
    
    func sendRecruitmentText(){
        //print("send recruitment text")
        var controller:MFMessageComposeViewController?
        
        if (MFMessageComposeViewController.canSendText()) {
            controller = MFMessageComposeViewController()
            controller!.body = "Atlantic is Hiring! Go to www.adminmatic.com/careers/\((self.appDelegate.loggedInEmployee?.ID)!) to apply today.  Help \(self.appDelegate.loggedInEmployee!.name) earn a bonus. Thanks"
            controller!.messageComposeDelegate = self
           
            layoutVars.getTopController().present(controller!, animated: true, completion: nil)
        }
        
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        //print("message delegate")
        self.layoutVars.simpleAlert(_vc: self, _title: "Message Sent. Thanks!", _message: "")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func showDepartments(){
        //print("show departments")
            self.deptCrewListViewController = DeptCrewListViewController(_empID: self.employee.ID, _empFirstName: self.employee.fName)
            navigationController?.pushViewController(self.deptCrewListViewController, animated: false )
    }
    
    @objc func showUsage(){
        //print("show usage")
            self.usageViewController = UsageViewController(_empID: (self.employee.ID),_empFName: (self.employee.fName))
            navigationController?.pushViewController(self.usageViewController, animated: false )
    }
    
    @objc func showShifts(){
        //print("show shifts")
            self.shiftsViewController = ShiftsViewController(_empID: self.employee.ID, _empFirstName: self.employee.fName)
            navigationController?.pushViewController(self.shiftsViewController, animated: false )
    }
    
    @objc func showPayroll(){
        //print("show payroll")
            self.payrollEntryViewController = PayrollEntryViewController(_employee: self.employee)
            navigationController?.pushViewController(self.payrollEntryViewController, animated: false )
    }
    
    @objc func showLicenses(){
        //print("showLicenses")
            self.licenseViewController = LicenseViewController(_employee: self.employee)
            navigationController?.pushViewController(self.licenseViewController, animated: false )
    }
    
    @objc func showTraining(){
        //print("showTraining")
        layoutVars.simpleAlert(_vc: self, _title: "Training System Coming Soon", _message: "")
    }
    
    @objc func logout(){
        self.appDelegate.logout()
    }
    
    
    
    //image methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let totalHeight: CGFloat = ((self.view.frame.width - 20) / 3 - 1)
            let totalWidth: CGFloat = ((self.view.frame.width - 20) / 3 - 1)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
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
        return self.imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
        //print("name = \(self.imageArray)")
        
       // print("name = \(self.imageArray[indexPath.row].name!)")
        cell.textLabel.text = " \(self.imageArray[indexPath.row].custName!)"
        cell.image = self.imageArray[indexPath.row]
        cell.activityView.startAnimating()
        
        print("thumb = \(self.imageArray[indexPath.row].thumbPath!)")
        Alamofire.request(self.imageArray[indexPath.row].thumbPath!).responseImage { response in
            //debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            //debugPrint(response.result)
            
            if let image = response.result.value {
                //print("image downloaded: \(image)")
                cell.imageView.image = image
                cell.activityView.stopAnimating()
            }
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
        //print("name = \(currentCell.image.name)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image, _ID: currentCell.image.ID)
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        imageDetailViewController.imageLikeDelegate = self
        
        
        currentImageIndex = indexPath.row
        
        
    }
    
    func getPrevNextImage(_next:Bool){
        if(_next == true){
            if(currentImageIndex + 1) > (self.imageArray.count - 1){
                currentImageIndex = 0
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
                
                
                
            }else{
                currentImageIndex = currentImageIndex + 1
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
                
            }
            
        }else{
            if(currentImageIndex - 1) < 0{
                currentImageIndex = self.imageArray.count - 1
                imageDetailViewController.image = self.imageArray[currentImageIndex]
                imageDetailViewController.layoutViews()
               
            }else{
                currentImageIndex = currentImageIndex - 1
                imageDetailViewController.image = self.imageArray[currentImageIndex]
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
    
    
    
    func updateLikes(_index:Int, _liked:String, _likes:String){
        //print("update likes _liked: \(_liked)  _likes\(_likes)")
        imageArray[_index].liked = _liked
        imageArray[_index].likes = _likes
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.bounds.maxY == scrollView.contentSize.height) {
            //print("scrolled to bottom")
            lazyLoad = 1
            batch += 1
            offset = batch * limit
            self.indicator = SDevIndicator.generate(self.view)!
            
            getImages()
        }
    }
    
    
    
    
    func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }

    
   
    
   
    
    @objc func showImage(_ sender: UITapGestureRecognizer){
        
        //print("show full screen")
        
        if self.employee.pic != nil{
            
            let image2 = Image2(_id: "", _fileName: "", _name: "", _width:"", _height: "", _description: "", _dateAdded: "", _createdBy: "", _type: "")
            image2.mediumPath = "https://adminmatic.com/uploads/general/medium/"+self.employee.pic!
            
            self.imageDetailViewController = ImageDetailViewController(_image: image2)
            
            navigationController?.pushViewController(imageDetailViewController, animated: false )
        }
        
    }
    
    
    
    @objc func handlePhone(){
        
        callPhoneNumber(self.phoneNumberClean)
        
        
    }
    
    @objc func emailHandler(){
        sendEmail(self.email)
    }
    
    
   
    
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
        
    }
    
    func showCustomerImages(_customer:String){
        //print("show customer images cust: \(_customer)")
        
        
        
    }
    
    //for No Internet recovery
    func reloadData() {
        self.getEmployeeData(_id: self.employee.ID)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
