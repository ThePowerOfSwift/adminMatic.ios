//
//  NoInternetViewController.swift
//  AdminMatic
//
//  Created by Nicholas Digiando on 12/12/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol NoInternetDelegate{
    func reloadData()
}
 
class NoInternetViewController: UIViewController {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var delegate:NoInternetDelegate!
    
    
    
    var warningImageView:UIImageView = UIImageView()
    var noInternetLbl:H1Label!
    
    
    
    
    var retryButton:Button = Button(titleText: "Retry Connection")
    
   
    init(){
        super.init(nibName:nil,bundle:nil)
        
    }
    
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        
       
        //navigationItem.leftBarButtonItem = nil
        
        navigationController?.navigationBar.barTintColor = layoutVars.navBarColor
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.layoutViews()
    }
    
    
    
    
    func layoutViews(){
        
        
       //let navigationBarAppearace = UINavigationBar.appearance()
       //navigationBarAppearace.barTintColor = layoutVars.navBarColor
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        //icon
        self.warningImageView.image = UIImage(named:"warning.png")
        warningImageView.contentMode = .scaleAspectFill
        warningImageView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(warningImageView)
        
        //label
        self.noInternetLbl = H1Label(text: "Lost Internet Connection")
        
        self.noInternetLbl.textAlignment = .center
        self.noInternetLbl.font = UIFont.boldSystemFont(ofSize: 28.0)
        self.noInternetLbl.textColor = layoutVars.buttonColor1
        self.noInternetLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(noInternetLbl)
        
       
        
        self.retryButton.addTarget(self, action: #selector(self.retry), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.retryButton)
        
        
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "thirdWidth": layoutVars.thirdWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "warningIcon":self.warningImageView,
            "noInternetLbl":self.noInternetLbl,
            "retryBtn":self.retryButton
            ] as [String:AnyObject]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-thirdWidth-[warningIcon(thirdWidth)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[noInternetLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
      
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[retryBtn]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-thirdWidth-[warningIcon(thirdWidth)]-12-[noInternetLbl(40)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[retryBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
      
        
        
    }
    
   
    
    
    
  
    
    @objc func retry(){
        print("retry")
        
        if CheckInternet.Connection(){
            navigationController?.popViewController(animated: false)
            if delegate != nil{
                delegate.reloadData()
            }
        }else{
            layoutVars.simpleAlert(_vc: self, _title: "Still No Internet", _message: "")
        }
        
        
        
      
        
        
    }
    
    
    
   
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    
   
    
    
    
    
    
}


