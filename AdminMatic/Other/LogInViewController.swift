//
//  LogInViewController.swift
//  AdminMatic2
//
//  Created by Nicholas Digiando on 11/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//


//params

//companyUnique  to be stored for all php calls
//userName
//password
//remember 0 or 1

//device

//logins[]


//sesionKey  to be stored for all php calls

//return company[]  colors etc.
//logins[attempt, lastAttempt]
//error[]  print error message to screen



import Foundation
import UIKit
import Alamofire
import SwiftyJSON

 
class LogInViewController: UIViewController, UITextFieldDelegate, NoInternetDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var json:JSON!
    var delegate:LoginDelegate!
    
    //var submitButton:UIBarButtonItem!
    
    
    
    var companyUnique:String = ""
    var userName:String = ""
    var password:String = ""
    var rememberMe:String = ""
    var device:String = ""
    var logins:[Login] = []
    var loginsToSend: [JSON] = []//data array
    
    

    var companyUniqueLbl:GreyLabel!
    var companyUniqueTxtField:PaddedTextField!
    
    var userNameLbl:GreyLabel!
    var userNameTxtField:PaddedTextField!
    
    var passwordLbl:GreyLabel!
    var passwordTxtField:PaddedTextField!
    
    //rememberMe switch
    var rememberMeLbl:GreyLabel!
    var rememberMeSwitch:UISwitch = UISwitch()
    
    var loginButton:Button = Button(titleText: "Log In")
    
   
    init(){
        super.init(nibName:nil,bundle:nil)
        
    }
    
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        title = "User Log In"
        view.backgroundColor = layoutVars.backgroundColor
       
        
        print("layoutVars.navBarColor = \(layoutVars.navBarColor)")
        
        
        navigationController?.navigationBar.barTintColor = layoutVars.navBarColor
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        self.layoutViews()
    }
    
    
    
    
    func layoutViews(){
        
        view.backgroundColor = layoutVars.backgroundColor
       
        UINavigationBar.appearance().backgroundColor = layoutVars.backgroundColor

        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //companyUnique
        self.companyUniqueLbl = GreyLabel()
        self.companyUniqueLbl.text = "Company Identifier:"
        self.companyUniqueLbl.textAlignment = .left
        self.companyUniqueLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(companyUniqueLbl)
        
       self.companyUniqueTxtField = PaddedTextField(placeholder: "Company Identifier")
        self.companyUniqueTxtField.autocapitalizationType = .none
        self.companyUniqueTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.companyUniqueTxtField.returnKeyType = .next
        self.companyUniqueTxtField.delegate = self
        self.companyUniqueTxtField.tag = 1
        safeContainer.addSubview(self.companyUniqueTxtField)
        
        //userName
        self.userNameLbl = GreyLabel()
        self.userNameLbl.text = "User Name:"
        self.userNameLbl.textAlignment = .left
        self.userNameLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(userNameLbl)
        
        self.userNameTxtField = PaddedTextField(placeholder: "User Name")
        self.userNameTxtField.autocapitalizationType = .none
        self.userNameTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.userNameTxtField.returnKeyType = .next
        self.userNameTxtField.delegate = self
        self.userNameTxtField.tag = 2
        safeContainer.addSubview(self.userNameTxtField)
        
        //password
        self.passwordLbl = GreyLabel()
        self.passwordLbl.text = "Password:"
        self.passwordLbl.textAlignment = .left
        self.passwordLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(passwordLbl)
        
        self.passwordTxtField = PaddedTextField(placeholder: "Password")
        self.passwordTxtField.autocapitalizationType = .none
        self.passwordTxtField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTxtField.returnKeyType = .done
        self.passwordTxtField.isSecureTextEntry = true
        self.passwordTxtField.delegate = self
        self.passwordTxtField.tag = 3
        safeContainer.addSubview(self.passwordTxtField)
        
        //rememberMe
        self.rememberMeLbl = GreyLabel()
        self.rememberMeLbl.text = "Remember Me:"
        self.rememberMeLbl.textAlignment = .left
        self.rememberMeLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(rememberMeLbl)
        
        
        rememberMeSwitch.isOn = false
        
        rememberMeSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        rememberMeSwitch.addTarget(self, action: #selector(LogInViewController.rememberMeSwitchValueDidChange(sender:)), for: .valueChanged)
        safeContainer.addSubview(rememberMeSwitch)
       
        
        self.loginButton.addTarget(self, action: #selector(self.login), for: UIControl.Event.touchUpInside)
        safeContainer.addSubview(self.loginButton)
        
        
        
        
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth, "nameWidth": layoutVars.fullWidth - 150, "navBottom":layoutVars.navAndStatusBarHeight + 8] as [String:Any]
        
        //auto layout group
        let equipmentViewsDictionary = [
            "companyUniqueLbl":self.companyUniqueLbl,
            "companyUniqueTxt":self.companyUniqueTxtField,
            
            "userNameLbl":self.userNameLbl,
            "userNameTxt":self.userNameTxtField,
            
            "passwordLbl":self.passwordLbl,
            "passwordTxt":self.passwordTxtField,
            
            "rememberMeLbl":self.rememberMeLbl,
            "rememberMeSwitch":self.rememberMeSwitch,
            
            "loginBtn":self.loginButton
            ] as [String:AnyObject]
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[companyUniqueLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[companyUniqueTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[userNameLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[userNameTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[passwordLbl]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[passwordTxt]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[rememberMeLbl]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[rememberMeSwitch]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[loginBtn]-15-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
       
       
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[companyUniqueLbl(40)][companyUniqueTxt(40)]-[userNameLbl(40)][userNameTxt(40)]-[passwordLbl(40)][passwordTxt(40)]-[rememberMeLbl(40)][rememberMeSwitch(40)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
      //  safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[companyUniqueLbl(40)][companyUniqueTxt(40)]-[userNameLbl(40)][userNameTxt(40)]-[passwordLbl(40)][passwordTxt(40)]-[rememberMeSwitch(40)]", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[loginBtn(40)]-10-|", options: [], metrics: metricsDictionary, views: equipmentViewsDictionary))
        
        
        
        if CheckInternet.Connection() != true{
           print("No Internet")
            let noInternetViewController = NoInternetViewController()
            navigationController?.pushViewController(noInternetViewController, animated: false)
        
            
        }
        
        
      
        
        
    }
    
    /*
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        
        textField.resignFirstResponder()
        

        
        return true
    }
 */
    
     
    
    
    
    func validateFields()->Bool{
        
        
        print("validate fields")
        
        if companyUniqueTxtField.text != companyUniqueTxtField.placeHolder{
            companyUnique = companyUniqueTxtField.text!
        }
        
        if userNameTxtField.text != userNameTxtField.placeHolder{
            userName = userNameTxtField.text!
        }
        
        if passwordTxtField.text != passwordTxtField.placeHolder{
            password = passwordTxtField.text!
        }
        
        
        
        
        //companyUnique check
        if(companyUnique == ""){
            print("provide companyUnique")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Field", _message: "Provide a Company Identifier")
            return false
        }
        
        //user check
        if(userName == ""){
            print("provide user")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Field", _message: "Provide a User Name")
            return false
        }
        
        //password
        if(password == ""){
            print("provide password")
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Incomplete Field", _message: "Provide a Password")
            return false
        }
        
       
        
        
        return true
        
        
    }
    
    /////////////// Switch Methods   ///////////////////////
      
       
       @objc func rememberMeSwitchValueDidChange(sender:UISwitch!)
       {
           //print("switchValueDidChange groupImages = \(groupImages)")
           
           if (sender.isOn == true){
               //print("on")
               rememberMe = "1"
           }
           else{
               //print("off")
               rememberMe = "0"
           }
       }
    
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    
    
    
    @objc func login(){
        print("log in")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        if(!validateFields()){
            print("didn't pass validation")
            return
        }
        
        
        //validate all fields
        
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        
        loginsToSend = []
        
        
        for (_, login) in logins.enumerated() {
                   //var usageQty = 0.0
                  // print("usage.qty = \(String(describing: usage.qty))")
                let JSONString = login.toJSONString(prettyPrint: true)
                    //let JSONString = login.toJSONString(prettyPrint: true)
                    loginsToSend.append(JSON(JSONString ?? ""))
                    print("usage JSONString = \(String(describing: JSONString))")
                  
                   
                   
               }
        
        
        
        self.device = modelIdentifier()
        
       
        
        let parameters:[String:String]
        parameters = ["companyUnique": self.companyUnique, "username": self.userName, "password": self.password, "remember": self.rememberMe, "device": self.device, "logins": "\(loginsToSend)"]
        
        
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/other/login.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    self.json = JSON(json)
                    
                    if self.json["errorArray"].count > 0{
                        self.layoutVars.playErrorSound()
                        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: "Login Error", _message: self.json["errorArray"][0].stringValue)
                        self.indicator.dismissIndicator()
                        return
                    }
                    
                    self.layoutVars.playSaveSound()
                   // let sessionKey = self.json["employee"]["sessionKey"].stringValue
                 //   let empID = self.json["employee"]["userID"].stringValue
                    
                    
                    
                    
                    
                    
                    let employee = Employee2(_ID: self.json["employee"]["ID"].stringValue, _name: self.json["employee"]["name"].stringValue, _lName: self.json["employee"]["lName"].stringValue, _fName: self.json["employee"]["fName"].stringValue, _userName: self.json["employee"]["userName"].stringValue, _userLevel: self.json["employee"]["userLevel"].stringValue, _userLevelName: self.json["employee"]["userLevelName"].stringValue)
                    
                    
                    employee.pic = self.json["employee"]["pic"].stringValue
                    employee.sessionKey = self.json["employee"]["sessionKey"].stringValue
                   // self.appDelegate.loggedInEmployee = employee
                    
                     
                     self.appDelegate.scheduleViewController.personalScheduleArray.removeAll()
                      self.appDelegate.scheduleViewController.personalScheduleLoaded = false
                    
                   
                    
                    
                    
                    self.appDelegate.defaults = UserDefaults.standard
                    self.appDelegate.defaults.setValue(self.companyUnique, forKey: loggedInKeys.companyUnique)
                    self.appDelegate.defaults.setValue(employee.sessionKey, forKey: loggedInKeys.sessionKey)
                    self.appDelegate.defaults.setValue(employee.ID, forKey: loggedInKeys.loggedInId)
                    self.appDelegate.defaults.synchronize()
                    
                    
                    print("sessionKey = \(String(describing: employee.sessionKey))")
                    print("companyUnique = \(self.companyUnique)")
                    print("ID = \(employee.ID)")
                    
                    
                    print("loggedInKeys.companyUnique = \(loggedInKeys.companyUnique)")
                    print("loggedInKeys.sessionKey = \(loggedInKeys.sessionKey)")
                    print("loggedInKeys.loggedInId = \(loggedInKeys.loggedInId)")
                    
                    
                    
                    //self.goBack()
                    self.delegate.login(_employee:employee)
                    
                   
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
        
        
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           //print("textFieldDidBeginEditing")
           
           //self.passTxt.reset()
        self.passwordTxtField.reset()
       }
       
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           
           //print("NEXT")
           switch (textField.tag) {
           case companyUniqueTxtField.tag:
               userNameTxtField.becomeFirstResponder()
               break;
           case userNameTxtField.tag:
                passwordTxtField.becomeFirstResponder()
                break;
           case passwordTxtField.tag:
               textField.resignFirstResponder()
               break;
           default:
               break;
           }
           return true
       }
       
       
    
    
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is called to remove the first responder for the text field.
    func resign() {
        self.resignFirstResponder()
    }
    
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
       }
    
    
}


