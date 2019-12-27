//
//  AppDelegate.swift
//  AdminMatic2
//
//  Created by Nick on 12/18/16.
//  Copyright © 2016 Nick. All rights reserved.
//


//  Find Compile Time Jam Ups Tool
// run in terminal set to same folder as app project
// returns text file of compliled functions and their compile time sorted slowest to fastest
// xcodebuild -workspace AdminMatic2.xcworkspace -scheme AdminMatic2 clean build | grep [1-9].[0-9]ms | sort -nr > culprits.txt


import UIKit
import CoreData
import Alamofire
import AlamofireImage
import SwiftyJSON
import AVFoundation
import SystemConfiguration
import  IQKeyboardManagerSwift

protocol MenuDelegate{
    func menuChange(_ menuItem:Int)
}

protocol TimeEntryDelegate{
    func editStartTime()
    func editStopTime()
    func editBreakTime()
    
}


protocol LoginDelegate{
    func login(_employee:Employee2)
    func logout()
}


struct defaultsKeys {
    static let loggedInId = ""
    static let loggedInName = ""
    static let loggedInPic = ""
    static let sessionKey = ""
    static let companyUnique = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MenuDelegate, LoginDelegate, NoInternetDelegate{
    
    var window: UIWindow?
    
    var layoutVars:LayoutVars = LayoutVars()
    var appVersion:String = "1.5.2"
    var navigationController:UINavigationController!
    
    var logInViewController:LogInViewController!
    var homeViewController:HomeViewController!
    var employeeListViewController:EmployeeListViewController!
    var customerListViewController:CustomerListViewController!
    var vendorListViewController:VendorListViewController!
    var itemListViewController:ItemListViewController!
    var employeeViewController:EmployeeViewController!
    var scheduleViewController:ScheduleViewController!
    var imageCollectionViewController:ImageCollectionViewController!
    var equipmentListViewController:EquipmentListViewController!
    var invoiceListViewController:InvoiceListViewController!
    var leadListViewController:LeadListViewController!
    var contractListViewController:ContractListViewController!
    
    var fieldsJson:JSON!
    var zones:[Zone2] = []
    
    var departments:[Department2] = []
    var crews:[Crew2] = []
    
    var employees:JSON!
    var employeeArray:[Employee2] = []
    
    var salesRepArray:[Employee2] = []
    
    var salesRepIDArray:[String] = []
    var salesRepNameArray:[String] = []
    
   
   // var customerHearIDs:[String] = []
    //var customerHearTypes:[String] = []
    
    //var contactTypeIDs:[String] = []
    //var contactTypeNames:[String] = []
    
    var contactTypes:[ContactType] = []
    
    var hearTypes:[HearType] = []
    
    var inspectionQuestions:[InspectionQuestion2] = []
    
    var loggedInEmployee:Employee2?
    var loggedInEmployeeJSON: JSON!

    
    
    var messageView:UIView?
    var messageImageView:UIImageView = UIImageView()
    var messageLabel:InfoLabel?
    var messageCloseBtn:Button?
   
    
    var defaults:UserDefaults!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        
        IQKeyboardManager.shared.enable = true
        
        defaults = UserDefaults.standard
        
        self.messageView = UIView()
        
        self.logInViewController = LogInViewController()
        self.logInViewController.delegate = self
        
        self.homeViewController = HomeViewController()
         
         self.employeeListViewController = EmployeeListViewController()
        self.employeeListViewController.delegate = self
         
         self.customerListViewController = CustomerListViewController()
         self.customerListViewController.delegate = self
         
         self.vendorListViewController = VendorListViewController()
         self.vendorListViewController.delegate = self
         
         self.itemListViewController = ItemListViewController()
         self.itemListViewController.delegate = self
         
         self.scheduleViewController = ScheduleViewController(_employeeID: "")
         self.scheduleViewController.delegate = self
         self.navigationController?.navigationBar.barTintColor = UIColor.white
         
         
         self.leadListViewController = LeadListViewController()
         self.leadListViewController.delegate = self
         
         self.equipmentListViewController = EquipmentListViewController()
         self.equipmentListViewController.delegate = self
         
         
         self.contractListViewController = ContractListViewController()
         self.contractListViewController.delegate = self
        
        self.invoiceListViewController = InvoiceListViewController()
        self.invoiceListViewController.delegate = self
        
       
         /*
        //style the nav bar
         let layoutVars:LayoutVars = LayoutVars()
         UIBarButtonItem.appearance().tintColor = layoutVars.backgroundColor
         UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
         
         
         let navigationBarAppearace = UINavigationBar.appearance()
         
         navigationBarAppearace.barTintColor = layoutVars.navBarColor
         
         //title
         UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.font: layoutVars.buttonFont, NSAttributedString.Key.foregroundColor: layoutVars.buttonTextColor ]
         //left right buttons
         UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: layoutVars.buttonFont, NSAttributedString.Key.foregroundColor: layoutVars.buttonTextColor], for: UIControl.State())
        */
        
       loginOrHome()
        
        
        return true
    }
    
    func loginOrHome(){
        
        print("loginOrHome()")
        navigationController = UINavigationController(rootViewController: homeViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController: navigationController, _delegate: self)
            return
        }
        
        print("defaults.string(forKey: loggedInKeys.loggedInId) = \(defaults.string(forKey: loggedInKeys.loggedInId))")
               if(defaults.string(forKey: loggedInKeys.loggedInId) != nil && defaults.string(forKey: loggedInKeys.loggedInId) != "" && defaults.string(forKey: loggedInKeys.loggedInId) != "0"){
                  // print("stored login data detected")
                   print("2a")
                   if(Int(defaults.string(forKey: loggedInKeys.loggedInId)!)! > 0){
                       print("getLoggedInEmployeeData")
                      // getLoggedInEmployeeData(_id: defaults.string(forKey: loggedInKeys.loggedInId)!)
                    
                    self.getCompanyData()
                       
                   }
                   //self.navigationController.popToRootViewController(animated: false)
                   navigationController = UINavigationController(rootViewController: homeViewController)
                    window?.rootViewController = navigationController
                    window?.makeKeyAndVisible()
                
                // let navigationBarAppearace = UINavigationBar.appearance()
                 //navigationBarAppearace.barTintColor = layoutVars.navBarColor
                 
                   
               }else{
                   print("2b")
                   
                   navigationController = UINavigationController(rootViewController: logInViewController)
                    window?.rootViewController = navigationController
                    window?.makeKeyAndVisible()
                
                //let navigationBarAppearace = UINavigationBar.appearance()
                //navigationBarAppearace.barTintColor = layoutVars.navBarColor
               }
        
    }
    
    func getCompanyData(){
        print("getCompanyData")
        
        homeViewController.indicator = SDevIndicator.generate(homeViewController.view)!
        
        let parameters:[String:String]
        parameters = ["companyUnique": defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": defaults.string(forKey: loggedInKeys.sessionKey)!]
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/fields.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
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
                    
                    //Error and warning handling
                    let errorData = try decoder.decode(ErrorArray.self, from: json!)
                    if errorData.errorArray.count > 0{
                         self.layoutVars.playErrorSound()
                            
                         self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Server Error", _message: errorData.errorArray[0])
                        self.homeViewController.indicator.dismissIndicator()
                         self.logout()
                         return
                    }
                    
                    let warningData = try decoder.decode(WarningArray.self, from: json!)
                    if warningData.warningArray.count > 0{
                         self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Warning", _message: warningData.warningArray[0])
                    }
                    
                    let departmentsData = try decoder.decode(DepartmentArray.self, from: json!)
                    self.departments = departmentsData.departments
                    
                    let crewsData = try decoder.decode(CrewArray.self, from: json!)
                    self.crews = crewsData.crews
                    
                    let zonesData = try decoder.decode(ZoneArray.self, from: json!)
                    self.zones = zonesData.zones
                    
                    let contactTypesData = try decoder.decode(ContactTypeArray.self, from: json!)
                    print("contactTypes.count = \(contactTypesData.contactTypes.count)")
                    for i in 0 ..< contactTypesData.contactTypes.count {
                        let id = contactTypesData.contactTypes[i].ID
                        // dont include jobSite, billing Addr or invoice Addr
                        if id != "3" && id != "4" && id != "14"{
                            self.contactTypes.append(contactTypesData.contactTypes[i])
                        }
                    }
                    print("contactTypes.count = \(self.contactTypes.count)")
                    
                    let hearTypesData = try decoder.decode(HearTypeArray.self, from: json!)
                    self.hearTypes = hearTypesData.hearTypes
                    print("hearTypes.count = \(self.hearTypes.count)")
                    
                    //php not giving these yet
                    let inspectionQuestionData = try decoder.decode(InspectionQuestionArray.self, from: json!)
                    self.inspectionQuestions = inspectionQuestionData.inspectionQuestions
                    
                    //not using terms, tax or salesTax
                   
                }catch let err{
                    print(err)
                }

        }
                
        self.employeeArray = []
        self.salesRepIDArray = []
        self.salesRepNameArray = []
        
        
        //Get employee list
        var parameters2:[String:String]
        parameters2 = ["companyUnique": defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": defaults.string(forKey: loggedInKeys.sessionKey)!]
        //print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/employees.php",method: .post, parameters: parameters2, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("employee response = \(response)")
            }
            .responseJSON() {
                response in
                
                
                do{
                    //created the json decoder
                    let json = response.data
                    let decoder = JSONDecoder()
                    
                    //Error and warning handling
                    let errorData = try decoder.decode(ErrorArray.self, from: json!)
                    if errorData.errorArray.count > 0{
                         self.layoutVars.playErrorSound()
                            
                         self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Server Error", _message: errorData.errorArray[0])
                        self.homeViewController.indicator.dismissIndicator()
                         self.logout()
                         return
                    }
                    let warningData = try decoder.decode(WarningArray.self, from: json!)
                    if warningData.warningArray.count > 0{
                         self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Warning", _message: warningData.warningArray[0])
                    }
                    
                    let parsedData = try decoder.decode(EmployeeArray.self, from: json!)
                    print("parsedData = \(parsedData)")
                    let employees = parsedData
                    self.employeeArray = employees.employees
                    let employeeCount = employees.employees.count
                    print("employee count = \(employeeCount)")
                    
                   
                    
                    for i in 0 ..< employeeCount {
                        //create an object
                        
                        //set loggedin emp object
                        if self.employeeArray[i].ID == self.defaults.string(forKey: loggedInKeys.loggedInId)! {
                            self.loggedInEmployee = employees.employees[i]
                        }
                        
                        //set sales rep array
                        if self.employeeArray[i].salesRep == "1"{
                            self.salesRepArray.append(self.employeeArray[i])
                            self.salesRepIDArray.append(self.employeeArray[i].ID)
                            self.salesRepNameArray.append(self.employeeArray[i].name)
                        }
                        
                        
                    }
                    
                    if self.employeeListViewController.employeeTableView != nil{
                        self.employeeListViewController.employeeTableView.reloadData()
                    }
                    
                    self.homeViewController.setLoggedInUserBtn()
                    
                    self.homeViewController.indicator.dismissIndicator()
                    
                   
                }catch let err{
                    print(err)
                }
                
        }
        
        
        
       
        navigationController = UINavigationController(rootViewController: homeViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
    }
    
    func menuChange(_ menuItem:Int){
        self.navigationController.popToRootViewController(animated: false)
        
        
        //let navigationBarAppearace = UINavigationBar.appearance()
        //navigationBarAppearace.barTintColor = layoutVars.buttonColor1
        
        switch (menuItem) {
        case 0:
            //print("Show Employee List")
            navigationController = UINavigationController(rootViewController: self.employeeListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            break
        case 1:
            self.navigationController = UINavigationController(rootViewController: self.customerListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            break
        case 2:
            //print("Show Vendor List")
            navigationController = UINavigationController(rootViewController: self.vendorListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            break
        case 3:
            //print("Show Item List")
            navigationController = UINavigationController(rootViewController: self.itemListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            break
        case 4:
          //  print("Show  Lead List")
            
            navigationController = UINavigationController(rootViewController: self.leadListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            break
            
        case 5:
            //print("Show  Contract List")
            navigationController = UINavigationController(rootViewController: self.contractListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            break;
        case 6:
            //print("Show Schedule")
            
            navigationController = UINavigationController(rootViewController: self.scheduleViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            break
        case 7:
            //print("Show  Performance")
            navigationController = UINavigationController(rootViewController: self.invoiceListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            break
        case 8:
            //print("Show  Images")
            if(self.imageCollectionViewController == nil){
                self.imageCollectionViewController = ImageCollectionViewController(_mode: "Gallery")
                self.imageCollectionViewController.delegate = self
            }
            
            navigationController = UINavigationController(rootViewController: self.imageCollectionViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
               
            break
        case 9:
            //print("Show  Equipment List")
            navigationController = UINavigationController(rootViewController: self.equipmentListViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
           
            
            break
            
        
            
        default://home
            //print("Show  Home Screen")
            navigationController = UINavigationController(rootViewController: self.homeViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            
            //let navigationBarAppearace = UINavigationBar.appearance()
            //navigationBarAppearace.barTintColor = layoutVars.backgroundColor
            
            break
        }
        
    }
    
    func login(_employee:Employee2){
        print("login \(_employee.name)")
        
        
        self.loggedInEmployee = _employee
        self.getCompanyData()
        
        
    }
    
  func logout(){
        print("logout")
        
        
        self.loggedInEmployee = nil
        
               self.scheduleViewController.personalScheduleArray.removeAll()
               self.scheduleViewController.personalScheduleLoaded = false
               
               self.defaults = UserDefaults.standard
               self.defaults.setValue("0", forKey: loggedInKeys.loggedInId)
               self.defaults.synchronize()
        
        navigationController = UINavigationController(rootViewController: logInViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    
    }
    

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.pc.PropEval" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return (urls[urls.count-1] as NSURL) as URL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "PropEval", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("PropEval.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
    
    
    // handles rotating

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if (rootViewController.responds(to: #selector(ImageDetailViewController.canRotate)) || rootViewController.responds(to: #selector(UsageViewController.canRotate)) || rootViewController.responds(to: #selector(SignatureViewController.canRotate)) || rootViewController.responds(to: #selector(PayrollSummaryViewController.canRotate))) {
                // Unlock landscape view orientations for this view controller
                return .allButUpsideDown;
            }
        }
        // Only allow portrait (standard behaviour)
        return .portrait;
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: (UITabBarController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of:(UINavigationController).self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        return rootViewController
    }
    
   
    
    func showMessage(_message:String)
    {
        
        //print("show message : \(_message)")
        //frame: CGRect(x: 0, y: 0, width: layoutVars.fullWidth, height: 50)
        
        self.messageView?.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.messageView?.isHidden = false
        
        self.messageView?.backgroundColor = layoutVars.backgroundColor
        self.messageView?.layer.borderColor = layoutVars.borderColor
        self.messageView?.layer.borderWidth = 1.0
        self.messageView?.translatesAutoresizingMaskIntoConstraints = false
        self.messageView?.alpha = 0.0
        
        Alamofire.request("https://adminmatic.com/uploads/general/thumbs/"+(self.loggedInEmployee?.pic)!).responseImage { response in
            //debugPrint(response)
            
            //print(response.request)
           // print(response.response)
            //debugPrint(response.result)
            
            if let image = response.result.value {
               // print("image downloaded: \(image)")
                self.messageImageView.image = image
            }
        }
        
       
        
        messageImageView.contentMode = .scaleAspectFill
        messageImageView.translatesAutoresizingMaskIntoConstraints = false
        self.messageView?.addSubview(self.messageImageView)
        
        self.messageLabel = InfoLabel()
        self.messageLabel?.text = "\(self.loggedInEmployee!.fName) \(_message)"
        self.messageView?.addSubview(self.messageLabel!)
        
        
        self.messageCloseBtn = Button(titleText: "")
        self.messageCloseBtn?.contentHorizontalAlignment = .left
        let closeIcon:UIImageView = UIImageView()
        closeIcon.backgroundColor = UIColor.clear
        closeIcon.contentMode = .scaleAspectFill
        closeIcon.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        let closeImg = UIImage(named:"closeIcon.png")
        closeIcon.image = closeImg
        self.messageCloseBtn?.addSubview(closeIcon)
        self.messageCloseBtn?.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.messageCloseBtn?.addTarget(self, action: #selector(self.closeMessage), for: UIControl.Event.touchUpInside)
        
        
        self.messageView?.addSubview(messageCloseBtn!)
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.view.addSubview(self.messageView!)
            
            
            //auto layout group
            let metricsDictionary = ["inputHeight":layoutVars.inputHeight, "navHeight": self.layoutVars.navAndStatusBarHeight] as [String : Any]
            
            
            let messageViewsDictionary = [
                "messageView":self.messageView!
                ] as [String:Any]
            
            topController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[messageView]|", options: [], metrics: nil, views: messageViewsDictionary))
            
            topController.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-75-[messageView(inputHeight)]", options: [], metrics: metricsDictionary, views: messageViewsDictionary))
            
            let messageViewsDictionary2 = [
                "messageImage":self.messageImageView,
                "messageLabel":self.messageLabel!,
                "messageClose":self.messageCloseBtn!
                ] as [String:Any]
            
            self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[messageImage(40)]-[messageLabel]-[messageClose(30)]-|", options: [], metrics: nil, views: messageViewsDictionary2))
            
            self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[messageImage(40)]", options: [], metrics: nil, views: messageViewsDictionary2))
             self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[messageLabel(30)]", options: [], metrics: nil, views: messageViewsDictionary2))
             self.messageView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[messageClose(30)]", options: [], metrics: nil, views: messageViewsDictionary2))
            
        }
        
        self.messageView?.layer.removeAllAnimations()
        UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
            self.messageView?.alpha = 1.0
        }, completion: {
            (value: Bool) in
            // create a sound ID, in this case its the tweet sound.
            let systemSoundID: SystemSoundID = 1023
            
            // to play sound
            AudioServicesPlaySystemSound (systemSoundID)
            
            
            UIView.animate(withDuration: 1.0, delay:2.0, animations: {
                self.messageView?.alpha = 0.0
            }, completion: {
                (value: Bool) in
                self.messageView?.isHidden = true
            })
        })
    }
    

    @objc func closeMessage(){
        //print("close message")
        self.messageView?.isHidden = true
        
    }
    
    func reloadData() {
        self.loginOrHome()
    }
        
}







