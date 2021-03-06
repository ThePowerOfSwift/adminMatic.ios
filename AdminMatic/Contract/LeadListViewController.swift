//
//  LeadListViewController.swift
//  AdminMatic2
//
//  Created by Nick on 11/7/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView

import Foundation
import UIKit
import Alamofire

// updates status icons without getting new db data
protocol LeadListDelegate{
    func getLeads(_openNewLead:Bool)
    
}

protocol LeadSettingsDelegate{
    func updateSettings(_status: String, _salesRep: String, _salesRepName: String, _zoneID: String, _zoneName: String)
}


class LeadListViewController: ViewControllerWithMenu, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, LeadListDelegate, LeadSettingsDelegate, NoInternetDelegate{
    
    var indicator: SDevIndicator!
    var layoutVars:LayoutVars = LayoutVars()
    
    var searchController:UISearchController!
    var searchTerm:String = ""
    //var leadsSearchResults:[Lead2] = []
    
    
    var shouldShowSearchResults:Bool = false
    
    var refreshControl: UIRefreshControl!
    var leadTableView: TableView!
    var countView:UIView = UIView()
    var countLbl:Label = Label()
    var addLeadBtn:Button = Button(titleText: "Add New Lead")
    var leadViewController:LeadViewController!
    
    
    var leadsArray:LeadArray = LeadArray(_leads: [])
    var leadsSearchResults:LeadArray = LeadArray(_leads: [])

    
    
    //settings
    
    var leadSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    
    var status:String = ""
    var salesRep:String = ""
    var salesRepName:String = ""
    var zoneID:String = ""
    var zoneName:String = ""
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = layoutVars.backgroundColor
        title = "Lead List"
        
        showLoadingScreen()
    }
    
    func showLoadingScreen(){
        //print("showLoadingScreen")
        title = "Loading..."
        
        getLeads(_openNewLead:false)
    }
    
    
    func getLeads(_openNewLead:Bool){
        print("getLeads")
        
        if CheckInternet.Connection() != true{
            self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
            return
        }
        
        indicator = SDevIndicator.generate(self.view)!
        
        
        self.leadsArray.leads = []
        
      
        
        //Get lead list
        var parameters:[String:String]
         parameters = ["status":self.status,"salesRep":self.salesRep,"zone":self.zoneID,"companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!]
        print("parameters = \(parameters)")
        
        self.layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/leads.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
                print("lead response = \(response)")
            }
            .responseJSON() {
                response in
                
                do{
                    //created the json decoder
                    let json = response.data
                    let decoder = JSONDecoder()
                    let parsedData = try decoder.decode(LeadArray.self, from: json!)
                    print("parsedData = \(parsedData)")
                    let leads = parsedData
                    let leadCount = leads.leads.count
                    print("invoice count = \(leadCount)")
                    for i in 0 ..< leadCount {
                        //create an object
                        print("create a lead object \(i)")
                        
                        leads.leads[i].custNameAndID = "\(leads.leads[i].customerName!) #\(leads.leads[i].ID)"
                        self.leadsArray.leads.append(leads.leads[i])
                    }
                    
                    self.indicator.dismissIndicator()
                    self.layoutViews()
                }catch let err{
                    print(err)
                }
                
        }
        
    }
    
    
    func layoutViews(){
        //print("Layout Views")
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
        //set container to safe bounds of view
        let safeContainer:UIView = UIView()
        safeContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(safeContainer)
        safeContainer.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        safeContainer.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        safeContainer.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        safeContainer.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search Leads"
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = layoutVars.buttonBackground
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
        
        if self.searchTerm != ""{
            self.searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
        
        
        
        self.leadTableView =  TableView()
        self.leadTableView.delegate  =  self
        self.leadTableView.dataSource  =  self
        self.leadTableView.rowHeight = 60.0
        self.leadTableView.register(LeadTableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.leadTableView)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        leadTableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: UIControl.Event.valueChanged)
        
        
        
        self.countView = UIView()
        self.countView.backgroundColor = layoutVars.backgroundColor
        self.countView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.countView)
        
        self.countLbl.translatesAutoresizingMaskIntoConstraints = false
        
        self.countView.addSubview(self.countLbl)
        
        self.addLeadBtn.layer.borderColor = UIColor.white.cgColor
        self.addLeadBtn.layer.borderWidth = 1.0
        self.addLeadBtn.addTarget(self, action: #selector(LeadListViewController.addLead), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.addLeadBtn)
        
        
        
        
        self.leadSettingsBtn.addTarget(self, action: #selector(LeadListViewController.leadSettings), for: UIControl.Event.touchUpInside)
        
        
        self.leadSettingsBtn.layer.borderColor = UIColor.white.cgColor
        self.leadSettingsBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.leadSettingsBtn)
        
        self.leadSettingsBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        
        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 11, y: 11, width: 28, height: 28)
        
        
        if(self.status != "" || self.salesRep != "" || self.zoneID != "" ){
            //print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }
        
        
        
        self.leadSettingsBtn.addSubview(settingsIcon)
        
        
        
        
        
        
    //auto layout group
        let viewsDictionary = [
            "leadTable":self.leadTableView,
            "countView":self.countView,
            "addLeadBtn":self.addLeadBtn,"leadSettingsBtn":leadSettingsBtn
            ] as [String : Any]
        let sizeVals = ["width": layoutVars.fullWidth,"height": self.view.frame.size.height ,"navBarHeight":self.layoutVars.navAndStatusBarHeight] as [String : Any]
        
    //////////////   auto layout position constraints   /////////////////////////////
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leadTable(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[countView(width)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[addLeadBtn][leadSettingsBtn(50)]|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[leadTable][countView(30)][addLeadBtn(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[leadTable][countView(30)][leadSettingsBtn(50)]-|", options: [], metrics: sizeVals, views: viewsDictionary))
        let viewsDictionary2 = [
            "countLbl":self.countLbl
            ] as [String : Any]
        
        
    //////////////   auto layout position constraints   /////////////////////////////
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[countLbl]|", options: [], metrics: sizeVals, views: viewsDictionary2))
        self.countView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[countLbl(20)]", options: [], metrics: sizeVals, views: viewsDictionary2))
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
    
    func filterSearchResults(){
        
        //print("filterSearchResults")
        self.leadsSearchResults.leads = []
        
       
        
        self.leadsSearchResults.leads = self.leadsArray.leads.filter({( aLead: Lead2) -> Bool in
            
            //return type name or name
            return (aLead.custNameAndID!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil  || aLead.description!.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)
        })
        
        
        
        
        self.leadTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        shouldShowSearchResults = true
        self.leadTableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        self.leadTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            self.leadTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        //print("self.leadsArray.count = \(self.leadsArray.count)")
        
        
        if shouldShowSearchResults{
            self.countLbl.text = "\(self.leadsSearchResults.leads.count) Lead(s) Found"
            return self.leadsSearchResults.leads.count
        } else {
            //print("self.leadsArray.count = \(self.leadsArray.count)")
            self.countLbl.text = "\(self.leadsArray.leads.count) Active Lead(s) "
            return self.leadsArray.leads.count
        }
        
        
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print("cellForRowAt")
        //print("leadsArray.count = \(self.leadsArray.count)")
       
        
        
        let cell:LeadTableViewCell = leadTableView.dequeueReusableCell(withIdentifier: "cell") as! LeadTableViewCell
        
        if shouldShowSearchResults{
            
            cell.lead = self.leadsSearchResults.leads[indexPath.row]
            
            let searchString = self.searchController.searchBar.text!.lowercased()
            
            //text highlighting
            
            let baseString:NSString = self.leadsSearchResults.leads[indexPath.row].custNameAndID! as NSString
            let highlightedText = NSMutableAttributedString(string: self.leadsSearchResults.leads[indexPath.row].custNameAndID!)
            
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            if let regexError = error {
                print("error \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            
            
            let baseString2:NSString = self.leadsSearchResults.leads[indexPath.row].description!  as NSString
            let highlightedText2 = NSMutableAttributedString(string: self.leadsSearchResults.leads[indexPath.row].description!)
            
            var error2: NSError?
            let regex2: NSRegularExpression?
            do {
                regex2 = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error2a as NSError {
                error2 = error2a
                regex2 = nil
            }
            if let regexError2 = error2 {
                print("error \(regexError2)")
            } else {
                for match in (regex2?.matches(in: baseString2 as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString2.length)))! as [NSTextCheckingResult] {
                    highlightedText2.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
                
            }
           
            
            cell.layoutViews()
            
            cell.titleLbl.attributedText = highlightedText
            
            cell.descriptionLbl.attributedText = highlightedText2
            
            
        } else {
            cell.lead = self.leadsArray.leads[indexPath.row]
            cell.layoutViews()
        }
        
        return cell;
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;
        let currentCell = tableView.cellForRow(at: indexPath!) as! LeadTableViewCell;
        self.leadViewController = LeadViewController(_lead: currentCell.lead)
        tableView.deselectRow(at: indexPath!, animated: true)
        self.leadViewController.delegate = self
        self.searchTerm = self.searchController.searchBar.text!
       
        if(self.searchController.isActive == true){
            self.searchTerm = self.searchController.searchBar.text!
            self.searchController.isActive = false
        }
        
        navigationController?.pushViewController(self.leadViewController, animated: false )
        
        
    }
    
    
    
    
    
    @objc func refresh(_ sender: AnyObject){
        //print("refresh")
        
        self.searchController.delegate = nil
        shouldShowSearchResults = false
        showLoadingScreen()
        
    }
    
    
    
    
    @objc func addLead(){
        //print("Add Lead")
        
        if(self.searchController.isActive == true){
            //print("search controller is active")
            self.searchTerm = self.searchController.searchBar.text!
           
            // or swift 4+
            self.searchController.isActive = false
            
        }
        
        
        let editLeadViewController = NewEditLeadViewController()
        editLeadViewController.delegate = self
        navigationController?.pushViewController(editLeadViewController, animated: false )
    }
    
    
    
    
    
    @objc func leadSettings(){
        //print("lead settings")
        
        let leadSettingsViewController = LeadSettingsViewController(_status: self.status,_salesRep: self.salesRep,_salesRepName: self.salesRepName,_zoneID: self.zoneID,_zoneName: self.zoneName)
        leadSettingsViewController.leadSettingsDelegate = self
        navigationController?.pushViewController(leadSettingsViewController, animated: false )
        
        
        
    }
    
    
    
    func updateSettings(_status: String, _salesRep: String, _salesRepName: String, _zoneID: String, _zoneName: String){
        //print("update settings status = \(_status) salesRep = \(_salesRep) salesRepName = \(_salesRepName)")
        self.status = _status
        self.salesRep = _salesRep
        self.salesRepName = _salesRepName
        self.zoneID = _zoneID
        self.zoneName = _zoneName
        
        showLoadingScreen()
        
    }
    
    
    
    
    
    func goBack(){
        _ = navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //print("view will appear")
        if self.searchTerm != ""{
            self.searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //for No Internet recovery
       func reloadData() {
           print("No Internet Recovery")
        getLeads(_openNewLead:false)
       }
    
    
}

