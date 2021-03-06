//
//  ContractItemViewController.swift
//  AdminMatic2
//
//  Created by Nick on 8/20/18.
//  Copyright © 2018 Nick. All rights reserved.
//

//  Edited for safeView


import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol EditContractItemDelegate{
    func updateContractItem(_contractItem:ContractItem2)
}
    
 

class ContractItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AttachmentDelegate, EditLeadDelegate, EditContractItemDelegate, NoInternetDelegate{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var layoutVars:LayoutVars = LayoutVars()
    
    
    var contractDelegate:EditContractDelegate!
    var leadDelegate:EditLeadDelegate!
    var indicator: SDevIndicator!

    
    var optionsButton:UIBarButtonItem!
    var editsMade:Bool = false
    var sortEditsMade:Bool = false
    
    var contract:Contract2!
    var contractItem:ContractItem2!
    
    //container views
    var itemView:UIView!
    var detailsView:UIView!
    
    var itemLbl:GreyLabel!
    
    var estLabel:Label!
    var estValueLabel:Label!
    
    var priceLabel:Label!
    var priceValueLabel:Label!
    
    var totalLabel:Label!
    var totalValueLabel:Label!
    
    var taxableLabel:Label!
    
    //details view

    var itemDetailsTableView:TableView!
    
    var tasksJson:JSON?
    
    var taskIDArray:[String] = []
    
    var json:JSON!
    var lead:Lead2?
    var leadTasksWaiting:String?
    var leadTasksWaitingBtn:Button = Button(titleText: "Open LeadTasks to Assign...")
    

    var imageUploadPrepViewController:ImageUploadPrepViewController!
    

    init(_contract:Contract2,_contractItem:ContractItem2){
        super.init(nibName:nil,bundle:nil)
        self.contract = _contract
        self.contractItem = _contractItem
        
        print("self.contractItem.ID = \(String(describing: self.contractItem.ID))")
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        
       // print("contractItem = \(self.contract.ID)")
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Contract Item #" + self.contractItem.ID
        
        /*
        //custom back button
        let backButton:UIButton = UIButton(type: UIButton.ButtonType.custom)
        backButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        backButton.setTitle("Back", for: UIControl.State.normal)
        backButton.titleLabel!.font =  layoutVars.buttonFont
        backButton.sizeToFit()
        let backButtonItem:UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem  = backButtonItem
 */
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.leftBarButtonItem = backButton
        
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func layoutViews(){
        //print("item view layoutViews 1")
        
        optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(ContractItemViewController.displayContractItemOptions))
        navigationItem.rightBarButtonItem = optionsButton
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        //////////   containers for different sections
        self.itemView = UIView()
        self.itemView.backgroundColor = layoutVars.backgroundColor
        self.itemView.layer.borderColor = layoutVars.borderColor
        self.itemView.layer.borderWidth = 1.0
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.itemView)
        
        self.detailsView = UIView()
        self.detailsView.backgroundColor = layoutVars.backgroundColor
        self.detailsView.translatesAutoresizingMaskIntoConstraints = false
        safeContainer.addSubview(self.detailsView)
        
        
        ////print("1")
        //auto layout group
        let viewsDictionary = [
            "view1":self.itemView,
            "view2":self.detailsView] as [String:AnyObject]
        
        let sizeVals = ["width": layoutVars.fullWidth as AnyObject,"height": 24  as AnyObject,"fullHeight":layoutVars.fullHeight - 224  as AnyObject]  as [String:AnyObject]
        
        //////////////////   auto layout position constraints   /////////////////////////////
        
        
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1(width)]", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[view2(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        safeContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(125)][view2]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        ///////////   wo item header section   /////////////
        
       
        
       
        self.itemLbl = GreyLabel()
        self.itemLbl.text = self.contractItem.name
        self.itemLbl.font = layoutVars.largeFont
        self.itemView.addSubview(self.itemLbl)
        
        self.estLabel = Label()
        self.estLabel.font = layoutVars.smallFont
        self.estLabel.text = "Estimated:"
        self.itemView.addSubview(self.estLabel)
        
        self.estValueLabel = Label()
        self.estValueLabel.font = layoutVars.smallBoldFont
        self.estValueLabel.text = self.contractItem.qty
        self.itemView.addSubview(self.estValueLabel)
        
        
        self.priceLabel = Label()
        self.priceLabel.font = layoutVars.smallFont
        self.priceLabel.text = "Unit Price:"
        self.itemView.addSubview(self.priceLabel)
        
        self.priceValueLabel = Label()
        self.priceValueLabel.font = layoutVars.smallBoldFont
        self.priceValueLabel.text = layoutVars.numberAsCurrency(_number: self.contractItem.price!)
        self.itemView.addSubview(self.priceValueLabel)
        
        
        
        self.totalLabel = Label()
        self.totalLabel.font = layoutVars.smallFont
        self.totalLabel.text = "Total:"
        self.itemView.addSubview(self.totalLabel)
        
        self.totalValueLabel = Label()
        self.totalValueLabel.font = layoutVars.smallBoldFont
        self.totalValueLabel.text = layoutVars.numberAsCurrency(_number: self.contractItem.total!)
        self.itemView.addSubview(self.totalValueLabel)
        
        self.taxableLabel = Label()
        self.taxableLabel.font = layoutVars.smallFont
        self.taxableLabel.textAlignment = .right
        if self.contractItem.taxCode == "0"{
            self.taxableLabel.text = "Non-Taxable"
        }else{
            self.taxableLabel.text = "Taxable"
        }
        
        self.itemView.addSubview(self.taxableLabel)
        
       
        
        
        let itemNameViewsDictionary = ["itemLbl":self.itemLbl,"estLbl":self.estLabel,"estValueLbl":self.estValueLabel,"priceLbl":self.priceLabel,"priceValueLbl":self.priceValueLabel,"totalLbl":self.totalLabel,"totalValueLbl":self.totalValueLabel,"taxableLbl":self.taxableLabel]  as [String:AnyObject]
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[itemLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        //self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[estLbl(100)][estValueLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[estLbl(100)][estValueLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[priceLbl(100)][priceValueLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        
        
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[totalLbl(100)][totalValueLbl][taxableLbl]-|", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(35)][estLbl(25)][priceLbl(25)][totalLbl(25)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(35)][estValueLbl(25)][priceValueLbl(25)][totalValueLbl(25)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        self.itemView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[itemLbl(35)][estLbl(25)][priceLbl(25)][taxableLbl(25)]", options: [], metrics: sizeVals, views: itemNameViewsDictionary))
        
        
        
        ///////////   Item Details Section   /////////////
        
        self.leadTasksWaitingBtn.addTarget(self, action: #selector(ContractItemViewController.assignLeadTasks), for: UIControl.Event.touchUpInside)
        //self.detailsView.addSubview(self.leadTasksWaitingBtn)
        
        
        self.taskIDArray = []
        for task in contractItem.tasks{
            let ID = task.ID!
            self.taskIDArray.append(ID)
        }
        
        
        self.itemDetailsTableView = TableView()
        self.itemDetailsTableView.delegate  =  self
        self.itemDetailsTableView.dataSource = self
        
        self.itemDetailsTableView.rowHeight = UITableView.automaticDimension
        self.itemDetailsTableView.estimatedRowHeight = 100.0
        
        
        self.itemDetailsTableView.register(ContractTaskTableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
        //print("leadTasksWaiting \(leadTasksWaiting)")
        //print("contractItem.type \(contractItem.type!)")
        
        if self.leadTasksWaiting! == "1" && self.contractItem.type! == "1"{
            
            showLeadTaskBtn()
            
          
        }else{
            
            hideLeadTaskBtn()
            
        }
    }
    
    
    
    @objc func displayContractItemOptions(){
        //print("display Item Options")
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            let actionSheet = UIAlertController(title: "Contract Item Options", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            actionSheet.view.backgroundColor = UIColor.white
            actionSheet.view.layer.cornerRadius = 5;
            
            actionSheet.addAction(UIAlertAction(title: "Edit Item", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                //print("display Edit View")
                self.editItem()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Sort Tasks", style: UIAlertAction.Style.default, handler: { (alert:UIAlertAction!) -> Void in
                //print("sort tasks")
                self.sortTasks()
            }))
            
            
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (alert:UIAlertAction!) -> Void in
            }))
            
            
            
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
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
                
                layoutVars.getTopController().present(nav, animated: true, completion: nil)
                break
            // It's an iPad
            case .unspecified:
                break
            default:
                layoutVars.getTopController().present(actionSheet, animated: true, completion: nil)
                break
                
                // Uh, oh! What could it be?
            }
        }
        
        
    }
    
    
    
    
    @objc func editItem(){
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            
            if self.contract.status == "1" || self.contract.status == "2" || self.contract.status == "3" || self.contract.status == "4"{
                let alertController = UIAlertController(title: "Edit Item?", message: "The customer may have already seen this contract. Are you sure you want to edit this item?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    //print("Cancel")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    //print("OK")
                    self.displayEditView()
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }else{
               displayEditView()
            }
            
        }
    }
    
    
    func displayEditView(){
        let editContractItemViewController = NewEditContractItemViewController(_contract: self.contract, _contractItem: self.contractItem)
        editContractItemViewController.editDelegate = self
        editContractItemViewController.loadItemList()
        self.navigationController?.pushViewController(editContractItemViewController, animated: false )
    }
    
    
    @objc func sortTasks(){
        if self.layoutVars.grantAccess(_level: 1,_view: self) {
            return
        }else{
            
            if self.contract.status == "1" || self.contract.status == "2" || self.contract.status == "3" || self.contract.status == "4"{
                let alertController = UIAlertController(title: "Sort Tasks?", message: "The customer may have already seen this contract. Are you sure you want to sort these tasks?", preferredStyle: UIAlertController.Style.alert)
                let cancelAction = UIAlertAction(title: "No", style: UIAlertAction.Style.destructive) {
                    (result : UIAlertAction) -> Void in
                    //print("Cancel")
                }
                
                let okAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    //print("OK")
                    self.setSortMode()
                    
                }
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                layoutVars.getTopController().present(alertController, animated: true, completion: nil)
            }else{
                self.setSortMode()
            }
            
        }
    }
    
    
    
    func setSortMode(){
        self.itemDetailsTableView.isEditing = !itemDetailsTableView.isEditing
        optionsButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ContractItemViewController.saveSort))
        navigationItem.rightBarButtonItem = optionsButton
        self.itemDetailsTableView.reloadData()
        
    }
    
   
    
    @objc func saveSort(_leave:Bool = false){
        //print("save sort")
        
        
        itemDetailsTableView.isEditing = !itemDetailsTableView.isEditing
        optionsButton = UIBarButtonItem(title: "Options", style: .plain, target: self, action: #selector(ContractItemViewController.displayContractItemOptions))
        navigationItem.rightBarButtonItem = optionsButton
        
        if sortEditsMade{
            
            if CheckInternet.Connection() != true{
                self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                return
            }
            
            indicator = SDevIndicator.generate(self.view)!
            
            let parameters = [
                "dataBase":"projects",
                "table": "contractTasks",
                "IDs": NSArray(array: self.taskIDArray),
                "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,
                "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!
                ] as [String : Any]
            
            
            
            
            //print("parameters = \(parameters)")
            
            layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/update/itemSort.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
                .responseString { response in
                    //print("task sort response = \(response)")
                }
                .responseJSON(){
                    response in
                    self.sortEditsMade = false
                    self.indicator.dismissIndicator()
                    if _leave{
                        _ = self.navigationController?.popViewController(animated: false)
                    }
                    
                    
            }
        }
       
    }
    
    
    
    
    
    func showLeadTaskBtn(){
        //print("showLeadTaskBtn")
        self.detailsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        self.detailsView.addSubview(self.leadTasksWaitingBtn)
        self.detailsView.addSubview(itemDetailsTableView)
        
        //auto layout group
        let itemDetailsViewsDictionary = [
            "view1":leadTasksWaitingBtn,
            "view2":itemDetailsTableView
            ]  as [String:AnyObject]
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view2]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1(40)][view2]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))


    }
    
    func hideLeadTaskBtn(){
        //print("hideLeadTaskBtn")
        self.detailsView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        self.detailsView.addSubview(itemDetailsTableView)
        
        let itemDetailsViewsDictionary = [
            "view1":itemDetailsTableView
            ]  as [String:AnyObject]
        
        
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
    
        self.detailsView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view1]|", options: [], metrics: nil, views: itemDetailsViewsDictionary))
        
    }
    

    
    /////////////// TableView Delegate Methods   ///////////////////////

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int!
        if itemDetailsTableView.isEditing{
            count = self.contractItem.tasks.count
        }else{
            count = self.contractItem.tasks.count + 1
        }
        
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemDetailsTableView.dequeueReusableCell(withIdentifier: "cell") as! ContractTaskTableViewCell
        cell.prepareForReuse()
        
        
        if(indexPath.row == self.contractItem.tasks.count){
            //cell add btn mode
            cell.layoutAddBtn()
        }else{
            
            cell.task = self.contractItem.tasks[indexPath.row]
            cell.layoutViews()
            cell.taskLbl.text = self.contractItem.tasks[indexPath.row].taskDescription
            
            if(self.contractItem.tasks[indexPath.row].images!.count == 0){
                cell.imageQtyLbl.text = "No Images"
            }else{
                if(self.contractItem.tasks[indexPath.row].images!.count == 1){
                    cell.imageQtyLbl.text = "1 Image"
                    
                }else{
                    cell.imageQtyLbl.text = "\(self.contractItem.tasks[indexPath.row].images!.count) Images"
                }
            }
            
            
            
            //print("image count = \(self.contractItem.tasks[indexPath.row].images.count)")
            
            if(self.contractItem.tasks[indexPath.row].images!.count > 0){
                //print("image path = \(self.contractItem.tasks[indexPath.row].images[0].thumbPath!)")
                cell.activityView.startAnimating()
              
                for image in self.contractItem.tasks[indexPath.row].images!{
                    image.setImagePaths(_thumbBase: self.contractItem.tasks[indexPath.row].thumbBase!, _mediumBase: self.contractItem.tasks[indexPath.row].mediumBase!, _rawBase: self.contractItem.tasks[indexPath.row].rawBase!)
                }
                
                if self.contractItem.tasks[indexPath.row].images![0].thumbPath != nil{
                    cell.setImageUrl(_url: "\(self.contractItem.tasks[indexPath.row].images![0].thumbPath!)")
                }
                
                
            }else{
                print("set blank image")
                cell.setBlankImage()
            }
            
        }
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //////print("You selected cell #\(indexPath.row)!")
        
        if(indexPath.row == self.contractItem.tasks.count){
            self.addTask()
        }else{
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
            imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Contract Task", _contractItemID: self.contractItem.ID, _contractTaskID: self.contractItem.tasks[indexPath.row].ID, _customerID: self.contract.customerID!, _images: self.contractItem.tasks[indexPath.row].images!, _allowImages:self.contract.allowImages!)
            
            imageUploadPrepViewController.layoutViews()
            imageUploadPrepViewController.groupDescriptionTxt.text = self.contractItem.tasks[indexPath.row].taskDescription
            imageUploadPrepViewController.groupDescriptionTxt.textColor = UIColor.black
            imageUploadPrepViewController.selectedID = self.contract.customerID!
            imageUploadPrepViewController.groupImages = true
            imageUploadPrepViewController.attachmentDelegate = self
            self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //indexPath
        
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            //print("delete task")
            self.deleteTask(_indexPath: indexPath)

        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    
    //reorder cells
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let ID = self.contractItem.tasks[sourceIndexPath.row].ID!
        self.taskIDArray.remove(at: sourceIndexPath.row)
        self.taskIDArray.insert(ID, at: destinationIndexPath.row)
        
        
        let task = self.contractItem.tasks[sourceIndexPath.row]
        self.contractItem.tasks.remove(at: sourceIndexPath.row)
        self.contractItem.tasks.insert(task, at: destinationIndexPath.row)
        
        sortEditsMade = true
    }
    
    

    @objc func assignLeadTasks(){
        //print("assign lead tasks")
        let leadTaskAssignViewController:LeadTaskAssignViewController = LeadTaskAssignViewController(_leadFromContractItem: self.lead!, _contractItem: self.contractItem)
        leadTaskAssignViewController.editDelegate = self
        self.navigationController?.pushViewController(leadTaskAssignViewController, animated: false)
    }
    
    
    @objc func deleteTask(_indexPath: IndexPath){
        
        //print("delete task")
        let alertController = UIAlertController(title: "Delete Task?", message: "Are you sure you want to delete this task?", preferredStyle: UIAlertController.Style.alert)
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
            
            
            self.editsMade = true
            
            var parameters:[String:String]
            parameters = [
                "taskID":self.contractItem.tasks[_indexPath.row].ID,
                "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,
                "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!
            ]
            self.contractItem.tasks.remove(at: _indexPath.row)
            
            //print("parameters = \(parameters)")
            self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/delete/contractTask.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON() {
                response in
                //print(response.request ?? "")  // original URL request
                //print(response.response ?? "") // URL response
                //print(response.data ?? "")     // server data
                //print(response.result)   // result of response serialization
                if let json = response.result.value {
                    print("JSON: \(json)")
                    
                    self.taskIDArray = []
                    for task in self.contractItem.tasks{
                        let ID = task.ID!
                        self.taskIDArray.append(ID)
                    }
                    self.itemDetailsTableView.reloadData()
                    
                    
                }
                }.responseString { response in
                    //print("response = \(response)")
            }
          
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        layoutVars.getTopController().present(alertController, animated: true, completion: nil)
    }
    
    
    func addTask(){
        //print("add task")
      
        let imageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Contract Task", _contractItemID: self.contractItem.ID, _contractTaskID: "0", _customerID: self.contract.customerID!, _images: [], _allowImages:self.contract.allowImages!)
        
        imageUploadPrepViewController.layoutViews()
        imageUploadPrepViewController.groupImages = true
        imageUploadPrepViewController.attachmentDelegate = self
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
    }
    
    
    func updateTable(_points:Int){
        //print("updateTable")
        editsMade = true
        getTasks()
    }
    
    
    
    
    func getTasks(){
        print("get tasks")
        
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        
       self.contractItem.tasks = []
        
        
        let parameters:[String:String]
        parameters = ["contractItemID": self.contractItem.ID,
        "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,
        "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!
        ]
        
        print("parameters = \(parameters)")
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/contractTasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("get tasks response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                do{
                    //created the json decoder
                    
                    let json = response.data
                    
                    
                    print("json = \(String(describing: json))")
                    
                    let decoder = JSONDecoder()
                    
                    let parsedData = try decoder.decode(ContractTaskArray.self, from: json!)
            
                    print("parsedData = \(parsedData)")
                    let contractTasks = parsedData
                    
                    for task in contractTasks.tasks{
                        for image in task.images!{
                            image.setImagePaths(_thumbBase: task.thumbBase!, _mediumBase: task.mediumBase!, _rawBase: task.rawBase!)
                        }
                        self.contractItem.tasks.append(task)
                    }
                    
                    self.itemDetailsTableView.reloadData()
                    
                    self.taskIDArray = []
                    for task in self.contractItem.tasks{
                        let ID = task.ID!
                        self.taskIDArray.append(ID)
                    }
                    
                    let indexPath = IndexPath(row: self.contractItem.tasks.count, section: 0)
                    self.itemDetailsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    
                }catch let err{
                    print(err)
                }
                
        }
        
    }

    func updateLead(_lead: Lead2, _newStatusValue:String){
        //print("update Lead")
        editsMade = true
        self.lead = _lead
        
        
        if self.lead!.statusID == "3"{
            self.hideLeadTaskBtn()
        }
        
        getLead()
        
    }
    
    
    func getLead() {
        //print(" GetLead  Lead Id \(self.contract.lead!.ID)")
        
        //get updated contractItem tasks
        self.getTasks()
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        
        // Show Loading Indicator
       
        self.contract.lead!.tasksArray = []
        let parameters:[String:String]
        parameters = ["leadID": self.contract.lead!.ID,
        "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,
        "sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!]
        //print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/leadTasks.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                //print("lead response = \(response)")
            }
            .responseJSON(){
                response in
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    self.json = JSON(json)
                   // self.parseJSON()
                }
                //print(" dismissIndicator")
        }
    }
    
    /*
    func parseJSON(){
        //tasks
        let taskCount = self.json["leadTasks"].count
        for n in 0 ..< taskCount {
            var taskImages:[Image] = []
            
            let imageCount = Int((self.json["leadTasks"][n]["images"].count))
            //print("imageCount: \(imageCount)")
            for p in 0 ..< imageCount {
                let fileName:String = (self.json["leadTasks"][n]["images"][p]["fileName"].stringValue)
                let thumbPath:String = "\(self.layoutVars.thumbBase)\(fileName)"
                let mediumPath:String = "\(self.layoutVars.mediumBase)\(fileName)"
                let rawPath:String = "\(self.layoutVars.rawBase)\(fileName)"
                //print("rawPath = \(rawPath)")
                
                let image = Image(_id: self.json["leadTasks"][n]["images"][p]["ID"].stringValue,_thumbPath: thumbPath,_mediumPath: mediumPath,_rawPath: rawPath,_name: self.json["leadTasks"][n]["images"][p]["name"].stringValue,_width: self.json["leadTasks"][n]["images"][p]["width"].stringValue,_height: self.json["leadTasks"][n]["images"][p]["height"].stringValue,_description: self.json["leadTasks"][n]["images"][p]["description"].stringValue,_dateAdded: self.json["leadTasks"][n]["images"][p]["dateAdded"].stringValue,_createdBy: self.json["leadTasks"][n]["images"][p]["createdByName"].stringValue,_type: self.json["leadTasks"][n]["images"][p]["type"].stringValue)
                image.customer = (self.json["leadTasks"][n]["images"][p]["customer"].stringValue)
                image.tags = (self.json["leadTasks"][n]["images"][p]["tags"].stringValue)
                //print("appending image")
                taskImages.append(image)
            }
            let task = Task2(_ID: self.json["leadTasks"][n]["ID"].stringValue, _sort: self.json["leadTasks"][n]["sort"].stringValue, _status: self.json["leadTasks"][n]["status"].stringValue, _task: self.json["leadTasks"][n]["taskDescription"].stringValue)
            
            
            
            
            
            //task.images = taskImages
            
            
            
            
            
            self.lead!.tasksArray!.append(task)
        }
        
    }
 */
    
    
    
    
    
    func updateContractItem(_contractItem: ContractItem2){
        //print("update Contract Item")
        editsMade = true
        self.contractItem = _contractItem
        
        
        
        self.layoutViews()
        
        
    }
    
    
    
    
    
    
    

    
    @objc func goBack(){
        
        if sortEditsMade == true{
            //print("sortEditsMade = true")
            let alertController = UIAlertController(title: "Sort Change", message: "Leave without saving?", preferredStyle: UIAlertController.Style.alert)
            let cancelAction = UIAlertAction(title: "Don't Save", style: UIAlertAction.Style.destructive) {
                (result : UIAlertAction) -> Void in
               
            }
            
            let okAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                //print("OK")
                self.saveSort(_leave:true)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.layoutVars.getTopController().present(alertController, animated: true, completion: nil)
        }
        
        
        if contractDelegate != nil && self.editsMade == true{
            contractDelegate.updateContract(_contract: self.contract)
            
        }
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
