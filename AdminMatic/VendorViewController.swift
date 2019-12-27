//
//  VendorViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/21/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire
//import SwiftyJSON
import MapKit
import CoreLocation

 

class VendorViewController: ViewControllerWithMenu, CLLocationManagerDelegate, NoInternetDelegate{
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var layoutVars:LayoutVars = LayoutVars()
    var indicator: SDevIndicator!
    
    //main variables passed to this VC
    var vendorID:String
    var vendor:Vendor2!
    
    //extra vendor properties, vendor object doesn't have'
    var phone: String = "No Phone Found"
    
    var lat: NSString?
    var lng: NSString?
    
    //vendor info
    var vendorView:UIView!
    var vendorLbl:GreyLabel!
    var balanceLbl:GreyLabel!
    var vendorPhoneBtn:UIButton!
    var phoneNumberClean:String!
    var vendorWebsiteBtn:UIButton!
    var vendorAddressBtn:UIButton!
    
    var mapView:MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var foundLocation:Bool = false
    
    init(_vendorID:String){
        self.vendorID = _vendorID
        
        super.init(nibName:nil,bundle:nil)
        
        print("init vendorID = \(self.vendorID)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Vendor"
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(VendorViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        getVendorData(_id: self.vendorID)
    }
    
    
     func getVendorData(_id:String){
        print("getVendorData id: \(_id)")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        let parameters:[String:String]
        parameters = ["id": _id,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/vendor.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("vendor response = \(response)")
            }
            .responseJSON(){
                response in
                
                    do{
                        //created the json decoder
                        let json = response.data
                        //print("json = \(json)")
                        
                        let decoder = JSONDecoder()
                        let parsedData = try decoder.decode(VendorArray.self, from: json!)
                        print("parsedData = \(parsedData)")
                        //self.vendor = parsedData
                        //let vendors = parsedData
                        self.vendor = parsedData.vendors[0]
                        
                        let contactCount:Int = self.vendor.contacts!.count
                             print("contactCount: \(contactCount)")
                        for contact in self.vendor.contacts! {
                            print("contactID: " + contact.ID)
                            switch  contact.type{
                             //phone
                             case "1":
                             print("case = phone")
                             if(contact.main == "1"){
                                self.phone = contact.value!
                             }
                             break
                             //email
                             case "2":
                             print("case = email")
                             break
                             default :
                                break
                             }
                                }
                        self.indicator.dismissIndicator()
                        self.layoutViews()
                    }catch let err{
                        print(err)
                    }
        }
     }
      
    func layoutViews(){
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        self.vendorView = UIView()
        self.vendorView.layer.borderColor = layoutVars.borderColor
        self.vendorView.layer.borderWidth = 1.0
        self.vendorView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.vendorView)
        
        //auto layout group
        let viewsDictionary = [
        "view1":self.vendorView] as [String:Any]
        
        let sizeVals = ["width": layoutVars.fullWidth,"height": 24,"fullHeight":layoutVars.fullHeight] as [String:Any]
        
        //////////////   auto layout position constraints   /////////////////////////////
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        ///////////   vendor contact section   /////////////
        
        //name
        self.vendorLbl = GreyLabel()
        self.vendorLbl.text = self.vendor.name
        self.vendorLbl.font = layoutVars.largeFont
        self.vendorView.addSubview(self.vendorLbl)
        
        //balance
        self.balanceLbl = GreyLabel()
        self.balanceLbl.font = layoutVars.smallFont
        self.balanceLbl.text = "Balance = $\(self.vendor.balance!)"
        self.vendorView.addSubview(self.balanceLbl)
        
        //phone
        self.phoneNumberClean = cleanPhoneNumber(self.vendor.phone)
        
        self.vendorPhoneBtn = Button()
        self.vendorPhoneBtn.translatesAutoresizingMaskIntoConstraints = false
        self.vendorPhoneBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.vendorPhoneBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        if self.vendor.phone == "" {
            self.vendorPhoneBtn.setTitle("No Phone Saved", for: UIControl.State.normal)
        }else{
            self.vendorPhoneBtn.setTitle(self.vendor.phone, for: UIControl.State.normal)
            self.vendorPhoneBtn.addTarget(self, action: #selector(self.phoneHandler), for: UIControl.Event.touchUpInside)
        }
        
        let phoneIcon:UIImageView = UIImageView()
        phoneIcon.backgroundColor = UIColor.clear
        phoneIcon.contentMode = .scaleAspectFill
        phoneIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let phoneImg = UIImage(named:"phoneIcon.png")
        phoneIcon.image = phoneImg
        self.vendorPhoneBtn.titleLabel?.addSubview(phoneIcon)
        
        self.vendorView.addSubview(self.vendorPhoneBtn)
        
        self.vendorWebsiteBtn = Button()
        self.vendorWebsiteBtn.translatesAutoresizingMaskIntoConstraints = false
        self.vendorWebsiteBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.vendorWebsiteBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        if self.vendor.website == "" {
            self.vendorWebsiteBtn.setTitle("No Website Saved", for: UIControl.State.normal)
            
        }else{
            self.vendorWebsiteBtn.setTitle(self.vendor.website, for: UIControl.State.normal)
            self.vendorWebsiteBtn.addTarget(self, action: #selector(VendorViewController.webHandler), for: UIControl.Event.touchUpInside)
        }
        
        let websiteIcon:UIImageView = UIImageView()
        websiteIcon.backgroundColor = UIColor.clear
        websiteIcon.contentMode = .scaleAspectFill
        websiteIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let websiteImg = UIImage(named:"webIcon.png")
        websiteIcon.image = websiteImg
        self.vendorWebsiteBtn.titleLabel?.addSubview(websiteIcon)
        
        self.vendorView.addSubview(self.vendorWebsiteBtn)
        
        self.vendorAddressBtn = Button()
        self.vendorAddressBtn.translatesAutoresizingMaskIntoConstraints = false
        self.vendorAddressBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        self.vendorAddressBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 40.0, bottom: 0.0, right: 0.0)
        
        if (self.vendor.address == "") {
            self.vendorAddressBtn.setTitle("No Location Saved", for: UIControl.State.normal)
        }else{
            self.vendorAddressBtn.setTitle(self.vendor.address, for: UIControl.State.normal)
            self.vendorAddressBtn.addTarget(self, action: #selector(VendorViewController.mapHandler), for: UIControl.Event.touchUpInside)
        }
        
        let addressIcon:UIImageView = UIImageView()
        addressIcon.backgroundColor = UIColor.clear
        addressIcon.contentMode = .scaleAspectFill
        addressIcon.frame = CGRect(x: -36, y: -6, width: 32, height: 32)
        let addressImg = UIImage(named:"mapIcon.png")
        addressIcon.image = addressImg
        self.vendorAddressBtn.titleLabel?.addSubview(addressIcon)
        self.vendorView.addSubview(self.vendorAddressBtn)
        
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        if self.vendor.lat != ""{
            mapView.setCenter(CLLocationCoordinate2D(latitude: Double(self.vendor.lat!)!,longitude:
            Double(self.vendor.lng!)!), animated: true)
    
            let location = CLLocationCoordinate2D(
                latitude: Double(self.vendor.lat!)!,
                longitude: Double(self.vendor.lng!)!
            )
        
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = self.vendor.name
        
            mapView.addAnnotation(annotation)
            
            mapView.showsUserLocation = true
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
        self.vendorView.addSubview(mapView)
        
        if (CLLocationManager.locationServicesEnabled())
        {
            print("location available")
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        //auto layout group
        let vendorsViewsDictionary = [
            "view2":self.vendorLbl,
            "balance":self.balanceLbl,
            "view3":self.vendorPhoneBtn,
            "view4":self.vendorWebsiteBtn,
            "view5":self.vendorAddressBtn,
            "map":self.mapView
        ] as [String : Any]
        //print("window width = \(layoutVars.fullWidth)")
    
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view2]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[balance]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view3]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view4]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view5]-10-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[map]-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
        self.vendorView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[view2(35)]-[balance(25)]-[view3(40)]-[view4(40)]-[view5(40)]-[map]-|", options: [], metrics: sizeVals, views: vendorsViewsDictionary))
    }
    
    
        
    @objc func phoneHandler(){
            callPhoneNumber(self.phoneNumberClean)
        }
        
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("monitoring")
    }
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        print("didUpdateLocations \(foundLocation)")
        if(foundLocation == false){
            var zoomRect:MKMapRect = MKMapRect.null
            for  annotation in mapView.annotations {
                let annotationPoint:MKMapPoint = MKMapPoint.init(annotation.coordinate)
                let pointRect:MKMapRect = MKMapRect.init(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0);
                if zoomRect.isNull {
                    zoomRect = pointRect;
                } else {
                    zoomRect = zoomRect.union(pointRect);
                }
            }
            mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets.init(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            foundLocation = true
        }
        
    }
    
    @objc func webHandler(){
        // sendEmail(self.email)
        openWebLink(self.vendor.website!)
    }
    
    @objc func mapHandler() {
        print("map handler")
        //need to set lat and lng
        openMapForPlace(self.vendor.name, _lat: self.vendor.lat! as NSString, _lng: self.vendor.lng! as NSString)
        
    }
    
    @objc func goBack(){
     _ = navigationController?.popViewController(animated: false)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
        getVendorData(_id: self.vendorID)
       }
    
}
