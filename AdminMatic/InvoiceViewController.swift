//
//  InvoiceViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/27/19.
//  Copyright © 2019 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire

/*
 Status
 0 = syncing to QB
 1 = pending
 2 = final
 3 = sent (printed/emailed)
 4 = paid
 5 = void
 */

protocol EditInvoiceDelegate{
    
    func suggestStatusChange(_emailCount:Int)
}

class InvoiceViewController: UIViewController, UITextFieldDelegate,  UITableViewDelegate, UITableViewDataSource, StackDelegate, EditInvoiceDelegate, NoInternetDelegate{
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    var invoice:Invoice2!
    
    var delegate:InvoiceListDelegate?
    var index:Int?
    
    var stackController:StackController!
    
    var optionsButton:UIBarButtonItem!
    var statusIcon:UIImageView = UIImageView()
    var statusTagIcon:UIImageView = UIImageView()
   
    var statusArray = ["Syncing to QB","Pending","Final","Sent","Paid","Void"]
    var statusValue: String!
    var customerBtn: Button!
    var infoView: UIView! = UIView()
    
    var titleLbl:GreyLabel!
    var titleValue:GreyLabel!
    
    var dateLbl:GreyLabel!
    var dateValue:GreyLabel!
    
    var chargeTypeLbl:GreyLabel!
    var chargeType:GreyLabel!
    
    var chargeTypeArray = ["NC - No Charge", "FL - Flat Priced", "T & M - Time & Material"]
    
    var salesRepLbl:GreyLabel!
    var salesRep:GreyLabel!
    
    var itemsLbl:GreyLabel!
    var itemsArray:[InvoiceItem2] = []
    
    var itemsTableView: TableView!
    
    var subLbl:GreyLabel!
    var subValueLbl:GreyLabel!
    var taxLbl:GreyLabel!
    var taxValueLbl:GreyLabel!
    
    var totalLbl:GreyLabel!
    
    init(_invoice:Invoice2){
        super.init(nibName:nil,bundle:nil)
        
        self.invoice = _invoice
        //print("contract init - total = \(contract.total)")
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewdidload")
        view.backgroundColor = layoutVars.backgroundColor
        //custom back button
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(InvoiceViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        showLoadingScreen()
    }
    
    
    func showLoadingScreen(){
        title = "Loading..."
        getInvoice()
    }
    
    
    //sends request for lead tasks
    func getInvoice() {
        //print(" GetContract  Contract Id \(self.contract.ID)")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        // Show Loading Indicator
        indicator = SDevIndicator.generate(self.view)!
        //reset task array
        self.itemsArray = []
        let parameters:[String:String]
        parameters = ["invoiceID": self.invoice.ID,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!]
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/invoice.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("invoice response = \(response)")
            }
            .responseJSON(){
                response in
                
                do{
                    //created the json decoder
                    let json = response.data
                    let decoder = JSONDecoder()
                    let parsedData = try decoder.decode(Invoice2.self, from: json!)
                    print("parsedData = \(parsedData)")
                    self.invoice = parsedData
                    if self.invoice.subTotal != nil{
                        self.invoice.subTotal = self.layoutVars.numberAsCurrency(_number: self.invoice.subTotal!)
                    }
                     if self.invoice.taxTotal != nil{
                        self.invoice.taxTotal = self.layoutVars.numberAsCurrency(_number: self.invoice.taxTotal!)
                    }
                    self.invoice.totalPrice = self.layoutVars.numberAsCurrency(_number: self.invoice.totalPrice)
                    self.layoutViews()
                }catch let err{
                    print(err)
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
    }
   
    
    
    func layoutViews(){
        print("layout views")
        title =  "Invoice #" + self.invoice.ID
        
        optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(InvoiceViewController.displayInvoiceOptions))
        navigationItem.rightBarButtonItem = optionsButton
    
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        if(self.infoView != nil){
            self.infoView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        stackController = StackController()
        stackController.delegate = self
        stackController.getStack(_type:3,_ID:self.invoice.ID)
        safeContainer.addSubview(stackController)
        
        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.backgroundColor = UIColor.clear
        statusIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusIcon)
        setStatus(status: invoice.status)
        
        statusTagIcon.translatesAutoresizingMaskIntoConstraints = false
        statusTagIcon.backgroundColor = UIColor.clear
        statusTagIcon.contentMode = .scaleAspectFill
        safeContainer.addSubview(statusTagIcon)
        
        self.customerBtn = Button(titleText: "\(self.invoice.customerName)")
        self.customerBtn.contentHorizontalAlignment = .left
        let custIcon:UIImageView = UIImageView()
        custIcon.backgroundColor = UIColor.clear
        custIcon.contentMode = .scaleAspectFill
        custIcon.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        let custImg = UIImage(named:"custIcon.png")
        custIcon.image = custImg
        self.customerBtn.addSubview(custIcon)
        self.customerBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 10)
        self.customerBtn.addTarget(self, action: #selector(self.showCustInfo), for: UIControl.Event.touchUpInside)
        
        safeContainer.addSubview(customerBtn)
        
        // Info Window
        self.infoView.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.backgroundColor = UIColor(hex:0xFFFFFc, op: 0.8)
        self.infoView.layer.borderWidth = 1
        self.infoView.layer.borderColor = UIColor(hex:0x005100, op: 1.0).cgColor
        self.infoView.layer.cornerRadius = 4.0
        safeContainer.addSubview(infoView)
        
        //title
        self.titleLbl = GreyLabel()
        self.titleLbl.text = "Title:"
        self.titleLbl.textAlignment = .left
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleLbl)
        
        self.titleValue = GreyLabel()
        if self.invoice.title != nil{
            self.titleValue.text = self.invoice.title!
        }
        self.titleValue.font = layoutVars.labelBoldFont
        self.titleValue.textAlignment = .left
        self.titleValue.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(titleValue)
        
        //date
        self.dateLbl = GreyLabel()
        self.dateLbl.text = "Date:"
        self.dateLbl.textAlignment = .left
        self.dateLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(dateLbl)
        
        self.dateValue = GreyLabel()
        self.dateValue.text = self.invoice.date
        self.dateValue.font = layoutVars.labelBoldFont
        self.dateValue.textAlignment = .left
        self.dateValue.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(dateValue)
        
        //charge type
        self.chargeTypeLbl = GreyLabel()
        self.chargeTypeLbl.text = "Charge Type:"
        self.chargeTypeLbl.textAlignment = .left
        self.chargeTypeLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeTypeLbl)
        
        self.chargeType = GreyLabel()
        if self.invoice.chargeType != nil{
            print("self.invoice.chargeType = \(String(describing: self.invoice.chargeType))")
            self.chargeType.text = self.chargeTypeArray[Int(self.invoice.chargeType!)! - 1]

        }
        self.chargeType.font = layoutVars.labelBoldFont
        self.chargeType.textAlignment = .left
        self.chargeType.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(chargeType)
        
        //sales rep
        self.salesRepLbl = GreyLabel()
        self.salesRepLbl.text = "Sales Rep:"
        self.salesRepLbl.textAlignment = .left
        self.salesRepLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRepLbl)
        
        self.salesRep = GreyLabel()
        if self.invoice.repName != nil{
            self.salesRep.text = self.invoice.repName
        }
        self.salesRep.font = layoutVars.labelBoldFont
        self.salesRep.textAlignment = .left
        self.salesRep.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(salesRep)
        
        //items
        self.itemsLbl = GreyLabel()
        self.itemsLbl.text = "Items:"
        self.itemsLbl.textAlignment = .left
        self.itemsLbl.translatesAutoresizingMaskIntoConstraints = false
        self.infoView.addSubview(itemsLbl)
        
        self.itemsTableView  =   TableView()
        self.itemsTableView.autoresizesSubviews = true
        self.itemsTableView.delegate  =  self
        self.itemsTableView.dataSource  =  self
        self.itemsTableView.layer.cornerRadius = 4
        self.itemsTableView.rowHeight = 90
        self.itemsTableView.register(InvoiceItemTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.itemsTableView.rowHeight = UITableView.automaticDimension
        self.itemsTableView.estimatedRowHeight = 60
        
        safeContainer.addSubview(self.itemsTableView)
        
        //subTotal
        self.subLbl = GreyLabel()
        self.subLbl.text =  "Subtotal:"
        self.subLbl.textAlignment = .right
        self.subLbl.font = layoutVars.extraSmallFont
        self.subLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(subLbl)
        
        self.subValueLbl = GreyLabel()
        self.subValueLbl.text =  self.invoice.subTotal!
        self.subValueLbl.textAlignment = .right
        self.subValueLbl.font = layoutVars.extraSmallFont
        self.subValueLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(subValueLbl)
        
        //taxTotal
        self.taxLbl = GreyLabel()
        self.taxLbl.text =  "Sales Tax:"
        self.taxLbl.textAlignment = .right
        self.taxLbl.font = layoutVars.extraSmallFont
        self.taxLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(taxLbl)
        
        self.taxValueLbl = GreyLabel()
        self.taxValueLbl.text =  self.invoice.taxTotal!
        self.taxValueLbl.textAlignment = .right
        self.taxValueLbl.font = layoutVars.extraSmallFont
        self.taxValueLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(taxValueLbl)
        
        //total
        self.totalLbl = GreyLabel()
        self.totalLbl.text =  self.invoice.totalPrice
        self.totalLbl.textAlignment = .right
        self.totalLbl.font = layoutVars.largeFont
        self.totalLbl.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(totalLbl)
        
        /////////  Auto Layout   //////////////////////////////////////
        
        let metricsDictionary = ["fullWidth": layoutVars.fullWidth - 30, "halfWidth": layoutVars.halfWidth] as [String:Any]
        
        //main views
        let viewsDictionary = [
            "stackController":self.stackController,
            "statusIcon":self.statusIcon,
            "statusTagIcon":self.statusTagIcon,
            "customerBtn":self.customerBtn,
            "info":self.infoView,
            "itemsLbl":self.itemsLbl,
            "table":self.itemsTableView,
            "subLbl":self.subLbl,
            "subValueLbl":self.subValueLbl,
            "taxLbl":self.taxLbl,
            "taxValueLbl":self.taxValueLbl,
            "totalLbl":self.totalLbl
        
            ] as [String:AnyObject]
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[stackController]|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[statusIcon(40)]-[customerBtn]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[info]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[itemsLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[table]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[subLbl]-[subValueLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[taxLbl]-[taxValueLbl]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[totalLbl(200)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[statusTagIcon(150)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[statusIcon(40)]", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(107)]-[itemsLbl(22)][table]-[subLbl(15)]-4-[taxLbl(15)]-4-[totalLbl(35)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
         safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[stackController(40)]-[customerBtn(40)]-[info(107)]-[itemsLbl(22)][table]-[subValueLbl(15)]-4-[taxValueLbl(15)]-4-[totalLbl(35)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[statusTagIcon(75)]-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
        
        //auto layout group
        let infoDictionary = [
            "titleLbl":self.titleLbl,
            "title":self.titleValue,
            "dateLbl":self.dateLbl,
            "date":self.dateValue,
            "chargeTypeLbl":self.chargeTypeLbl,
            "chargeType":self.chargeType,
            "salesRepLbl":self.salesRepLbl,
            "salesRep":self.salesRep
            ] as [String:AnyObject]
        
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLbl]-[title]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[dateLbl]-[date]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[chargeTypeLbl]-[chargeType]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[salesRepLbl]-[salesRep]-|", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLbl(22)][dateLbl(22)][chargeTypeLbl(22)][salesRepLbl(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
        self.infoView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[title(22)][date(22)][chargeType(22)][salesRep(22)]", options: [], metrics: metricsDictionary, views: infoDictionary))
    }
    
   
    @objc func showCustInfo() {
        ////print("SHOW CUST INFO")
        let customerViewController = CustomerViewController(_customerID: self.invoice.customerID,_customerName: self.invoice.customerName)
        navigationController?.pushViewController(customerViewController, animated: false )
    }
    
    func removeViews(){
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        if self.invoice.items != nil{
            count = self.invoice.items!.count
        }else{
            count = 0
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell:InvoiceItemTableViewCell = itemsTableView.dequeueReusableCell(withIdentifier: "cell") as! InvoiceItemTableViewCell
        cell.invoiceItem = self.invoice.items![indexPath.row]
        cell.layoutViews()
        
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    @objc func displayInvoiceOptions(){
        print("display Options")
        if self.layoutVars.grantAccess(_level: 2,_view: self) {
            return
        }else{
            
            let actionSheet = UIAlertController(title: "Invoice Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            if invoice.status == "1"{
                actionSheet.addAction(UIAlertAction(title: "Mark as Final", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                    print("markInvoiceFinal")
                    self.markInvoiceFinal()
                }))
            }
            
            if invoice.status == "2"{
                actionSheet.addAction(UIAlertAction(title: "Mark as Pending", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                    print("markInvoicePending")
                    self.markInvoicePending()
                }))
            }
            
            
            actionSheet.addAction(UIAlertAction(title: "Send Invoice", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                print("send invoice")
                self.sendInvoice()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                //self.present(actionSheet, animated: true, completion: nil)
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
            // It's an iPhone
            case .pad:
                let nav = UINavigationController(rootViewController: actionSheet)
                nav.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = nav.popoverPresentationController as UIPopoverPresentationController?
                actionSheet.preferredContentSize = CGSize(width: 500.0, height: 600.0)
                popover?.sourceView = self.view
                popover?.sourceRect = CGRect(x: 100.0, y: 100.0, width: 0, height: 0)
                
                //self.present(nav, animated: true, completion: nil)
                layoutVars.getTopController().present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                //self.present(actionSheet, animated: true, completion: nil)
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
        }
        
        
    }
    
    
    
    @objc func markInvoiceFinal(_send:Bool = false){
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        let parameters:[String:String]
        parameters = ["invoiceID": self.invoice.ID,"final":"1","sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!]
        
        indicator = SDevIndicator.generate(self.view)!
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/invoiceFinal.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("send response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    self.invoice.status = "2"
                    self.setStatus(status: self.invoice.status)
                    if self.delegate != nil{
                         self.delegate!.updateInvoice(_atIndex: self.index!, _status: self.invoice.status)
                    }
                    if _send{
                        self.displayEmailView()
                    }else{
                        self.layoutVars.simpleAlert(_vc: self, _title: "Invoice Marked to Final", _message: "")
                    }
                    
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
        
    }
   
    
    @objc func markInvoicePending(){
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        let parameters:[String:String]
        parameters = ["invoiceID": self.invoice.ID,"final":"0","sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!]
        
        indicator = SDevIndicator.generate(self.view)!
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/invoiceFinal.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("send response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    self.invoice.status = "1"
                    self.setStatus(status: self.invoice.status)
                    
                    if self.delegate != nil{
                        self.delegate!.updateInvoice(_atIndex: self.index!, _status: self.invoice.status)
                    }
                    
                    self.layoutVars.simpleAlert(_vc: self, _title: "Invoice Marked to Pending", _message: "")
                }
                print(" dismissIndicator")
                self.indicator.dismissIndicator()
        }
        
    }
    
    
    @objc func sendInvoice(){
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        switch invoice.status {
        case "0":
            layoutVars.simpleAlert(_vc: self, _title: "Can't Send Invoice", _message: "Invoice needs to sync with Quick Books before sending.  Try back in a few minutes.")
            return
        case "1":
            
            let alertController = UIAlertController(title: "Mark to Final?", message: "Invoice is pending.  Please mark to Final before sending", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Final", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                //self.addItem()
                self.markInvoiceFinal(_send:true)
                return
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
            
        case "3":
            
            let alertController = UIAlertController(title: "Invoice Already Sent", message: "This invoice has been already sent.  Do you want to re-send?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                self.displayEmailView()
                return
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
        case "4":
            
            let alertController = UIAlertController(title: "Invoice Already Paid", message: "This invoice has been already been paid.  Do you want to send it anyway?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                self.displayEmailView()
                return
                
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        case "5":
            
            let alertController = UIAlertController(title: "Invoice Voided", message: "This invoice has been voided.  Do you want to send it anyway?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                print("Yes")
                
                self.displayEmailView()
                return
                
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        default:
            print("default")
        }
        
       
        
        self.displayEmailView()
        
    }
    
    func displayEmailView(){
        print("display email view")
        
        let emailViewController:EmailViewController = EmailViewController(_customerID: self.invoice.customerID, _customerName: self.invoice.customerName, _type: "1", _docID: self.invoice.ID)
        
        
        emailViewController.invoiceDelegate = self
        
        navigationController?.pushViewController(emailViewController, animated: false )
        
        
    }
    
    
    
    func suggestStatusChange(_emailCount:Int) {
        print("suggestStatusChange")
        
        var messageString:String = "Email Sent"
        if _emailCount > 1{
            messageString = "Emails Sent"
        }
        if self.invoice.status == "2" {
            
            
            
            let alertController = UIAlertController(title: messageString, message:  "Set invoice status to SENT?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                
                //self.getContract()
                
                
                
            }
            let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                
                
                if CheckInternet.Connection() != true{
                    self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                    return
                }
                
                
                
                var parameters:[String:String]
                parameters = [
                    "invoiceID":self.invoice.ID,
                    "emailed":"1",
                    "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!,
                    "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!
                ]
                
                self.invoice.status = "3"
                self.setStatus(status: "3")
                print("parameters = \(parameters)")
                if self.delegate != nil{
                    self.delegate?.updateInvoice(_atIndex: self.index!, _status: self.invoice.status)
                }
                
                self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/changeInvoiceEmailed.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                    response in
                    print(response.request ?? "")  // original URL request
                    print(response.result)   // result of response serialization
                    
                    self.layoutVars.playSaveSound()
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true)
        }else{
            self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: messageString, _message: "")
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
    
    // This triggers the textFieldDidEndEditing method that has the textField within it.
    //  This then triggers the resign() method to remove the keyboard.
    //  We use this in the "done" button action.
    func endEditingNow(){
        self.view.endEditing(true)
    }
    
    // What to do when a user finishes editting
    private func textFieldDidEndEditing(textField: UITextField) {
        resign()
    }
    
    func setStatus(status: String) {
        print("set status \(status)")
        switch (status) {
        case "0":
            let statusImg = UIImage(named:"syncIcon.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagSyncIcon.png")
            statusTagIcon.image = statusTagImg
            
            break;
        case "1":
            let statusImg = UIImage(named:"pendingIcon.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagPendingIcon.png")
            statusTagIcon.image = statusTagImg
            break;
        case "2":
            let statusImg = UIImage(named:"inProgressStatus.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagFinalIcon.png")
            statusTagIcon.image = statusTagImg
            break;
        case "3":
            let statusImg = UIImage(named:"acceptedStatus.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagSentIcon.png")
            statusTagIcon.image = statusTagImg
            break;
        case "4":
            let statusImg = UIImage(named:"doneStatus.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagPaidIcon.png")
            statusTagIcon.image = statusTagImg
            break;
        case "5":
            let statusImg = UIImage(named:"cancelStatus.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagVoidIcon.png")
            statusTagIcon.image = statusTagImg
            break;
        
        default:
            let statusImg = UIImage(named:"unDoneStatus.png")
            statusIcon.image = statusImg
            
            let statusTagImg = UIImage(named:"tagSyncIcon.png")
            statusTagIcon.image = statusTagImg
            break;
        }
    }
    
    //Stack Delegates
    func displayAlert(_title: String) {
        self.layoutVars.simpleAlert(_vc: self.layoutVars.getTopController(), _title: _title, _message: "")
    }
    
    func newLeadView(_lead:Lead2){
        let leadViewController:LeadViewController = LeadViewController(_lead: _lead)
        self.navigationController?.pushViewController(leadViewController, animated: false )
    }
    
    func newContractView(_contract:Contract2){
        let contractViewController:ContractViewController = ContractViewController(_contract: _contract)
        self.navigationController?.pushViewController(contractViewController, animated: false )
    }
    
    func newWorkOrderView(_workOrder:WorkOrder2){
        let workOrderViewController:WorkOrderViewController = WorkOrderViewController(_workOrderID: _workOrder.ID)
        self.navigationController?.pushViewController(workOrderViewController, animated: false )
    }
    
    func newInvoiceView(_invoice:Invoice2){
        
        
    }
    
    
    func setLeadTasksWaiting(_leadTasksWaiting:String){
        
    }
    
    //following 3 functions not used in this view
    func suggestNewContractFromLead(){
        print("suggestNewContractFromLead")
    }
    func suggestNewWorkOrderFromLead(){
        print("suggestNewWorkOrderFromLead")
    }
    func suggestNewWorkOrderFromContract(){
        print("suggestNewWorkOrderFromContract")
    }
    
    
    @objc func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
        getInvoice()
       }
    
}
