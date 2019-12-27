//
//  CustomerContactViewController.swift
//  AdminMatic2
//
//  Created by Nick on 1/13/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//edited for safeView

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol ContactListDelegate{
   
    func updateList()
}


class CustomerContactViewController: ViewControllerWithMenu, UITableViewDelegate, UITableViewDataSource, ContactListDelegate, NoInternetDelegate{
    
    var editCustomerDelegate:EditCustomerDelegate!
    
    var loadingLabel:UILabel!
    var totalCustomers:Int!
    var loadedCustomers:Int!
    var loadingString:String = "Connecting..."
    var searchController:UISearchController!
    
    
    var customerNotesLbl:GreyLabel!
    var customerNotesTxtView:UITextView = UITextView()
    
    var contactTableView:TableView!
    
    var layoutVars:LayoutVars = LayoutVars()
    
    var customerID:String!
    var contacts:[Contact2]!
    var notes:String!
    
    let viewsConstraint_V:NSArray = []
    let viewsConstraint_V2:NSArray = []
    
    
    init(_customerID:String,_contacts:[Contact2],_notes:String){
        super.init(nibName:nil,bundle:nil)
        self.contacts = _contacts
        self.customerID = _customerID
        self.notes = _notes
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customer Info"
        
        //custom back button
        /*
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(CustomerContactViewController.goBack), for: UIControl.Event.touchUpInside)
        backButton.titleLabel?.textColor = layoutVars.buttonColor1
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
        */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        view.backgroundColor = layoutVars.backgroundColor
        self.layoutViews()
    }
    
    func updateContactList(_contacts:[Contact2]){
        print("update contact list")
        self.contacts = _contacts
        
        layoutViews()
        
    }
    
    func layoutViews(){
        
        print("layoutViews")
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        
        DispatchQueue.main.async {
            self.customerNotesTxtView.contentOffset = CGPoint.zero
            self.customerNotesTxtView.scrollRangeToVisible(NSRange(location:0, length:0))
            
           
        }
        
        
        
        
        //instructions
        self.customerNotesLbl = GreyLabel()
        self.customerNotesLbl.text = "Customer Notes:"
        self.customerNotesLbl.textAlignment = .left
        self.customerNotesLbl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.customerNotesLbl)
        
        //self.instructionsView = UITextView()
        self.customerNotesTxtView.layer.borderWidth = 1
        self.customerNotesTxtView.layer.borderColor = UIColor(hex:0x005100, op: 0.2).cgColor
        self.customerNotesTxtView.layer.cornerRadius = 4.0
        
        self.customerNotesTxtView.backgroundColor = UIColor.white
        var custNotes:String
        if notes == ""{
            custNotes = "No notes on file."
        }else{
            custNotes = notes
        }
        self.customerNotesTxtView.text = custNotes
        self.customerNotesTxtView.font = layoutVars.smallFont
        self.customerNotesTxtView.isEditable = false
        self.customerNotesTxtView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.customerNotesTxtView)
        
        
        
        self.contactTableView = TableView()
        self.contactTableView.delegate  =  self
        self.contactTableView.dataSource = self
        self.contactTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.contactTableView.sectionHeaderHeight = 0
        self.contactTableView.tableHeaderView = UIView(frame: CGRect(x:0, y:0, width:self.contactTableView.bounds.size.width, height:5));
        
        self.view.addSubview(self.contactTableView)
        
        
        
        self.customerNotesLbl.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.customerNotesLbl.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        self.customerNotesLbl.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.customerNotesLbl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.customerNotesTxtView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.customerNotesTxtView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 30.0).isActive = true
        self.customerNotesTxtView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.customerNotesTxtView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.contactTableView.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.contactTableView.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 118.0).isActive = true
        self.contactTableView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        self.contactTableView.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor).isActive = true
        
        
    }
    
    
    
    /////////////// TableView Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contacts.count + 1
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contactTableView.dequeueReusableCell(withIdentifier: "cell") as! ContactTableViewCell
        contactTableView.rowHeight = 50.0
        
       // if(indexPath.row == self.customerJSON["customer"]["contacts"].count){
        if(indexPath.row == self.contacts.count){
            cell.layoutAddBtn()
            return cell
        }else{
            
            cell.contact = contacts[indexPath.row]
            
           
            
            //switch  self.customerJSON["customer"]["contacts"][indexPath.row]["type"].stringValue {
            switch  contacts[indexPath.row].type {
                
            //main phone
            case "1":
                cell.iconView.image = UIImage(named:"phoneIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Main Phone"
                
                break
            //main email
            case "2":
                cell.iconView.image = UIImage(named:"emailIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Main Email"
                break
                
            //billing  address
            case "3":
                cell.iconView.image = UIImage(named:"mapIcon.png")
                
                cell.nameLbl?.text = cell.contact.fullAddress
                cell.detailLbl?.text = "Billing Address"
                break
                
            //jobSite address
            case "4":
                cell.iconView.image = UIImage(named:"mapIcon.png")
                
                cell.nameLbl?.text = cell.contact.fullAddress
                cell.detailLbl?.text = "Jobsite Address"
                
                break
                
            //website
            case "5":
                cell.iconView.image = UIImage(named:"webIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Website"
                
                break
                
            //alt contact
            case "6":
                cell.iconView.image = UIImage(named:"personIcon.png")
                
                cell.nameLbl?.text = cell.contact.name
                cell.detailLbl?.text = "Alt Contact"
                
                break
                
            //fax
            case "7":
                cell.iconView.image = UIImage(named:"phoneIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Fax"
                
                
                break
            //alt phone
            case "8":
                cell.iconView.image = UIImage(named:"phoneIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Alt Phone"
                
                
                break
            //alt email
            case "9":
                cell.iconView.image = UIImage(named:"emailIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Alt Email"
                
                
                break
            //mobile
            case "10":
                cell.iconView.image = UIImage(named:"phoneIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Mobile"
                
                
                break
            //alt mobile
            case "11":
                cell.iconView.image = UIImage(named:"phoneIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Alt Mobile"
                
                
                break
            //home phone
            case "12":
                cell.iconView.image = UIImage(named:"phoneIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Home Phone"
                
                
                break
            //alt email
            case "13":
                //cell.type = .fax
                cell.iconView.image = UIImage(named:"emailIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Alt Email"
                
                
                break
            //invoice address
            case "14":
                //cell.type = .fax
                cell.iconView.image = UIImage(named:"mapIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Invoice Address"
                
                
                break
            //alt jobsite
            case "15":
                //cell.type = .fax
                cell.iconView.image = UIImage(named:"mapIcon.png")
                
                cell.nameLbl?.text = cell.contact.value
                cell.detailLbl?.text = "Alt Jobsite"
                
                
                break
                
                
            default :
                break
                
            }
            
            
            
            // set preferred state
            //if self.customerJSON["customer"]["contacts"][indexPath.row]["preferred"].stringValue == "1"{
            if self.contacts[indexPath.row].preferred == "1"{
                cell.contentView.backgroundColor = UIColor.yellow
            }
            return cell
        }
            
            
            
       
        
        
        
        
        // println("self.customersArray!.count = \(self.customersArray.count)")
        
        
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // print("You selected cell #\(indexPath.row)!")
        
        
        if(indexPath.row == self.contacts.count){
            tableView.deselectRow(at: indexPath, animated: false)
            self.addContact()
        }else{
            let indexPath = tableView.indexPathForSelectedRow;
            
            let currentCell = tableView.cellForRow(at: indexPath!) as! ContactTableViewCell;
            
            
            switch  currentCell.contact.type{
            //phone
            case "1":
                
                
                callPhoneNumber(currentCell.contact.value!)
                
                break
            case "2":
                sendEmail(currentCell.contact.value!)
                break
            case "3":
                openMapForPlace(currentCell.contact.name!, _lat: currentCell.contact.lat! as NSString, _lng: currentCell.contact.lng! as NSString)
                break
            case "4":
                openMapForPlace(currentCell.contact.name!, _lat: currentCell.contact.lat! as NSString, _lng: currentCell.contact.lng! as NSString)
                break
            case "5":
                openWebLink(currentCell.contact.value!)
                break
            case "6":
                //openWebLink(currentCell.contact.value)
                break
            case "7":
                //openWebLink(currentCell.contact.value)
                break
            case "8":
                callPhoneNumber(currentCell.contact.value!)
                break
            case "9":
                sendEmail(currentCell.contact.value!)
                break
            case "10":
                callPhoneNumber(currentCell.contact.value!)
                break
            case "11":
                callPhoneNumber(currentCell.contact.value!)
                break
            case "12":
                callPhoneNumber(currentCell.contact.value!)
                break
            case "13":
                sendEmail(currentCell.contact.value!)
                break
            case "14":
                //callPhoneNumber(currentCell.contact.value!)
                break
            case "15":
                openMapForPlace(currentCell.contact.name!, _lat: currentCell.contact.lat! as NSString, _lng: currentCell.contact.lng! as NSString)
                break
                
                
                //not doing anything for person or fax
                
            default:
                break
                
                
            }
        }
        
        
        
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if(indexPath.row != contacts.count){
            
            if contacts[indexPath.row].type != "3" && contacts[indexPath.row].type != "4" && contacts[indexPath.row].type != "14"{
                return true
            }else{
                return false
            }
            
        }else{
            return false
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            //print("edit tapped")
            self.editContact(_row:indexPath.row)
            
        }
        edit.backgroundColor = UIColor.gray
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("delete tapped")
            self.deleteContact(_row: indexPath.row)
        }
        delete.backgroundColor = UIColor.red
        
            return [delete, edit]
        
        
    }
    
    
    
    
    
    
    
    func deleteContact(_row:Int){
        //print("delete item")
        
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            let alertController = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete this contact?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
                //print("No")
                return
            }
            
            let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("Yes")
                
                
                
                if CheckInternet.Connection() != true{
                    self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                    return
                }
                
                var parameters:[String:AnyObject]
                parameters = [
                    "contactID":self.contacts[_row].ID as AnyObject,"custID":self.customerID as AnyObject, "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject
                ]
                print("parameters = \(parameters)")
                
                
                
                
                self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/delete/customerEmail.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                    .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                    .responseString { response in
                        //print("delete response = \(response)")
                    }
                    .responseJSON(){
                        response in
                        if let json = response.result.value {
                            print("JSON: \(json)")
                         self.updateList()
                            
                        }
                        
                        
                        
                }
                
            }
            
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    
    func editContact(_row:Int){
        //print("edit item")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            let newEditContactViewController:NewEditContactViewController = NewEditContactViewController(_custID: self.customerID, _contact:self.contacts[_row])//NewEditContactViewController(_custID: self.customerJSON["customer"]["ID"].string!)
            newEditContactViewController.delegate = self
            self.navigationController?.pushViewController(newEditContactViewController, animated: false )
        }
    }
    
   
    
    
    func addContact(){
        //print("add item")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            let newEditContactViewController:NewEditContactViewController = NewEditContactViewController(_custID: self.customerID)
            newEditContactViewController.delegate = self
            self.navigationController?.pushViewController(newEditContactViewController, animated: false )
        }
        
    }
    
   
    
    
    
    
    
    func updateList(){
        print("update list")
       // getContacts()
        
        editCustomerDelegate.updateCustomer(_customerID: self.customerID)
        
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
       }
    
}
