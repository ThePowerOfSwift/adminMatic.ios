//
//  ImageCollectionViewController.swift
//  AdminMatic2
//
//  Created by Nick on 2/14/17.
//  Copyright © 2017 Nick. All rights reserved.
//

//  Edited for safeView
import Foundation
import UIKit
import Alamofire
import DKImagePickerController

protocol ImageViewDelegate{
    func getPrevNextImage(_next:Bool)
    func showCustomerImages(_customer:String)
    func refreshImages(_images:[Image2])
}
 
protocol ImageSettingsDelegate{
    func updateSettings(_uploadedBy:String,_portfolio:String,_attachment:String,_task:String,_order:String,_customer:String)
}
    
protocol ImageLikeDelegate{
    func updateLikes(_index:Int, _liked:String, _likes:String)
}


class ImageCollectionViewController: ViewControllerWithMenu, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, ImageViewDelegate, ImageSettingsDelegate, ImageLikeDelegate, NoInternetDelegate,UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource  {
        
    var layoutVars:LayoutVars!
    var indicator: SDevIndicator!
    var totalImages:Int!
    var imageArray:ImageArray = ImageArray(_images: [])
    var shouldShowSearchResults:Bool = false
    var searchTerm:String = "" // used to retain search when leaving this view and having to deactivate search to enable device rotation - a real pain
    var searchController:UISearchController!
    
    var tagsResultsTableView:TableView = TableView()
    var tags = [String]()
    var tagsSearchResults:[String] = []
    var selectedTag:String = ""
    
    var selectedImages:ImageArray = ImageArray(_images: [])
    var selectedUIImages:[UIImage] = []
    
    
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    var imageCollectionView: UICollectionView?
    var addImageBtn:Button = Button(titleText: "Add Images")
    
    var imageSettingsBtn:Button = Button(titleText: "")
    let settingsIcon:UIImageView = UIImageView()
    let settingsImg = UIImage(named:"settingsIcon.png")
    let settingsEditedImg = UIImage(named:"settingsEditedIcon.png")
    
    var currentImageIndex:Int!
    var imageDetailViewController:ImageDetailViewController!
    var portraitMode:Bool = true
    var refresher:UIRefreshControl!
    
    //setting vars
    var uploadedBy:String = "0"
    var portfolio:String = "0"
    var attachment:String = "0"
    var task:String = "0"
    var customer:String = ""
    
    var order:String = "ID DESC"
    
    
    var lazyLoad = 0
    var limit = 100
    var offset = 0
    var batch = 0
    
    
    
    var i:Int = 0 //number of times thia vc is displayed
    
    init(_mode:String){
        super.init(nibName:nil,bundle:nil)
        print("init _mode = \(_mode)")
        title = "Images"
        self.view.backgroundColor = layoutVars.backgroundColor
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       layoutVars = LayoutVars()
        
            getTags()
       
    }
    
    func getTags(){
        print("getTags")
        // Show Indicator
        
        if CheckInternet.Connection() != true{
                          self.layoutVars.showNoInternetVC(_navController:self.appDelegate.navigationController, _delegate: self)
                          return
                      }
               
               
        
        
        
        indicator = SDevIndicator.generate(self.view)!
        
        let parameters:[String:String]
        parameters = ["companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)!,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)!]
        
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/tags.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .validate()    // or, if you just want to check status codes, validate(statusCode: 200..<300)
            .responseString { response in
               // print("tags response = \(response)")
            }
            
            .responseJSON(){
                response in
                
                
                
                
                
                //native way
                do {
                    if let data = response.data,
                        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let tags = json["tags"] as? [[String: Any]] {
                        let tagCount = tags.count
                       // print("tag count = \(tagCount)")
                        
                        for i in 0 ..< tagCount {
                            
                            self.tags.append(tags[i]["name"] as! String)
                        }
                    }
                     self.getImages()
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
        }
    }
    
   
    
    override func viewWillAppear(_ animated: Bool) {
       print("viewWillAppear")
       //print("imagesSearchResults.count = \(imagesSearchResults.count)")
        currentImageIndex = 0
        if(searchTerm != ""){
            searchController.isActive = true
            self.searchController.searchBar.text = searchTerm
        }
        
        if CheckInternet.Connection() != true{
           print("no internet")
            let noInternetViewController = NoInternetViewController()
           noInternetViewController.delegate = self
            navigationController?.pushViewController(noInternetViewController, animated: false)
            return
        }
        
        
        
       
    }
    
    func getImages() {
        //remove any added views (needed for table refresh
        
        print("get images")
        
        
        if CheckInternet.Connection() != true{
            print("no internet")
            let noInternetViewController = NoInternetViewController()
           noInternetViewController.delegate = self
            navigationController?.pushViewController(noInternetViewController, animated: false)
            return
        }
        
        var parameters = [String:AnyObject]()
        
        
        if selectedTag == ""{
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "limit": self.limit as AnyObject,"offset": self.offset as AnyObject, "order":self.order as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }else{
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "tag":self.selectedTag as AnyObject, "limit": self.limit as AnyObject,"offset": self.offset as AnyObject, "order":self.order as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }
 
        if(self.uploadedBy != "0"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "uploadedBy": self.uploadedBy as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }
        
        if(self.portfolio == "1"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject, "tag":self.selectedTag as AnyObject, "limit": self.limit as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "portfolio": self.portfolio as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }
        
        if(self.attachment == "1"){
             parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "fieldnotes": self.attachment as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }
        
        if(self.task == "1"){
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "task": self.task as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }
        
        if self.customer != ""{
            parameters = ["loginID": self.appDelegate.loggedInEmployee?.ID as AnyObject,"limit": "\(self.limit)" as AnyObject,"offset": "\(self.offset)" as AnyObject, "order":self.order as AnyObject, "customer": self.customer as AnyObject, "companyUnique": self.appDelegate.defaults.string(forKey: loggedInKeys.companyUnique)! as AnyObject,"sessionKey": self.appDelegate.defaults.string(forKey: loggedInKeys.sessionKey)! as AnyObject]
        }
        
        print("parameters = \(parameters)")
        
        layoutVars.manager.request("https://www.adminmatic.com/cp/app/functions/get/images.php",method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
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
                  
                    let images = parsedData
                    
                    let imageCount = images.images.count
                    print("image count = \(imageCount)")
                    for i in 0 ..< imageCount {
                        //create an object
                        print("create a image object \(i)")
                        
                        images.images[i].index = i
                        images.images[i].setImagePaths(_thumbBase: images.thumbBase!, _mediumBase: images.mediumBase!, _rawBase: images.rawBase!)
                        self.imageArray.images.append(images.images[i])
                        
                    }
                    
                    if(self.lazyLoad == 0){
                        self.layoutViews()
                    }else{
                        self.lazyLoad = 0
                        self.imageCollectionView?.reloadData()
                    }
                    
                    self.indicator.dismissIndicator()
                    //self.layoutViews()
                }catch let err{
                    print(err)
                }
                
                self.indicator.dismissIndicator()
        }
    }
   
    
    
    func layoutViews(){
        
        
        
        print("layoutViews collection")
        // Close Indicator
        indicator.dismissIndicator()
        
        self.view.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        
        
       
            // Initialize and perform a minimum configuration to the search controller.
            searchController = UISearchController(searchResultsController: nil)
            searchController.searchBar.placeholder = "Search Image Tags"
            searchController.searchResultsUpdater = self
            searchController.delegate = self
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.hidesNavigationBarDuringPresentation = false
        
        
        
        //workaround for ios 11 larger search bar
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchController.searchBar)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        
        
        imageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        
        imageCollectionView?.translatesAutoresizingMaskIntoConstraints = false
          
        imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            
        self.view.addSubview(imageCollectionView!)
        
        imageCollectionView?.dataSource = self
        imageCollectionView?.delegate = self
        imageCollectionView?.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        imageCollectionView?.backgroundColor = UIColor.darkGray
        
        imageCollectionView?.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        imageCollectionView?.topAnchor.constraint(equalTo: view.safeTopAnchor).isActive = true
        imageCollectionView?.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        imageCollectionView?.bottomAnchor.constraint(equalTo: view.safeBottomAnchor,constant: -50.0 ).isActive = true
        
        let refresher = UIRefreshControl()
        self.imageCollectionView!.alwaysBounceVertical = true
        
       
       refresher.addTarget(self, action: #selector(ImageCollectionViewController.loadData), for: .valueChanged)
        imageCollectionView!.addSubview(refresher)
        
        
        self.tagsResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.tagsResultsTableView.delegate  =  self
        self.tagsResultsTableView.dataSource = self
        self.tagsResultsTableView.register(TagTableViewCell.self, forCellReuseIdentifier: "tagCell")
        self.tagsResultsTableView.alpha = 0.0
        self.tagsResultsTableView.separatorStyle = .none
        self.tagsResultsTableView.backgroundColor = UIColor.clear
        self.view.addSubview(self.tagsResultsTableView)
        
        
        self.addImageBtn.addTarget(self, action: #selector(ImageCollectionViewController.addImage), for: UIControl.Event.touchUpInside)
        
        self.addImageBtn.translatesAutoresizingMaskIntoConstraints = false
        self.addImageBtn.layer.borderColor = UIColor.white.cgColor
        self.addImageBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.addImageBtn)
        
        self.addImageBtn.leftAnchor.constraint(equalTo: view.safeLeftAnchor).isActive = true
        self.addImageBtn.widthAnchor.constraint(equalToConstant: self.view.frame.width - 50.0).isActive = true
        self.addImageBtn.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        self.addImageBtn.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true
        
        
        
        self.imageSettingsBtn.addTarget(self, action: #selector(ImageCollectionViewController.imageSettings), for: UIControl.Event.touchUpInside)
        
        self.imageSettingsBtn.translatesAutoresizingMaskIntoConstraints = false
        self.imageSettingsBtn.layer.borderColor = UIColor.white.cgColor
        self.imageSettingsBtn.layer.borderWidth = 1.0
        self.view.addSubview(self.imageSettingsBtn)
        
        self.imageSettingsBtn.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        
        self.imageSettingsBtn.rightAnchor.constraint(equalTo: view.safeRightAnchor).isActive = true
        self.imageSettingsBtn.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        self.imageSettingsBtn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.imageSettingsBtn.bottomAnchor.constraint(equalTo: view.safeBottomAnchor).isActive = true

        
        
        settingsIcon.backgroundColor = UIColor.clear
        settingsIcon.contentMode = .scaleAspectFill
        settingsIcon.frame = CGRect(x: 11, y: 11, width: 28, height: 28)
        
        
        if(self.uploadedBy != "0" || self.portfolio != "0" || self.attachment != "0" || self.task != "0" || self.order != "ID DESC" || self.customer != ""){
            print("changes made")
            settingsIcon.image = settingsEditedImg
        }else{
            settingsIcon.image = settingsImg
        }

        
        
        self.imageSettingsBtn.addSubview(settingsIcon)
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if(portraitMode == true){
            let totalHeight: CGFloat = (self.view.frame.width / 3 - 1)
            let totalWidth: CGFloat = (self.view.frame.width / 3 - 1)
            return CGSize(width: ceil(totalWidth), height: ceil(totalHeight))
        }else{
            let totalHeight: CGFloat = (self.view.frame.width / 5 - 1)
            let totalWidth: CGFloat = (self.view.frame.width / 5 - 1)
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
        
        
        
        return self.imageArray.images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("making cells")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! ImageCollectionViewCell
        cell.backgroundColor = UIColor.darkGray
        cell.activityView.startAnimating()
        cell.imageView.image = nil
        
       
        print("name = \(self.imageArray.images[indexPath.row].name)")
        
        
        cell.textLabel.text = " \(self.imageArray.images[indexPath.row].custName!)"
       
        
        
        print("thumb = \(self.imageArray.images[indexPath.row].thumbPath!)")
        
        
        //print("imgURL = \(imgURL)")
        
        Alamofire.request(self.imageArray.images[indexPath.row].thumbPath!).responseImage { response in
            debugPrint(response)
            
            //print(response.request)
            //print(response.response)
            debugPrint(response.result)
            
            if let image = response.result.value {
                print("image downloaded: \(image)")
                cell.imageView.image = image
                cell.image = self.imageArray.images[indexPath.row]
                cell.activityView.stopAnimating()
            }
        }
        
     
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let currentCell = imageCollectionView?.cellForItem(at: indexPath) as! ImageCollectionViewCell
        
       // print("mode = \(self.mode)")
        
        imageDetailViewController = ImageDetailViewController(_image: currentCell.image)
        imageCollectionView?.deselectItem(at: indexPath, animated: true)
        navigationController?.pushViewController(imageDetailViewController, animated: false )
        imageDetailViewController.delegate = self
        imageDetailViewController.imageLikeDelegate = self
        
      
        
        currentImageIndex = indexPath.row
        

    }
    
    /////////////// Search Methods   ///////////////////////
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //print("updateSearchResultsForSearchController \(searchController.searchBar.text)")
        filterSearchResults()
    }
    
    func filterSearchResults(){
        //print("filterSearchResults")
        
        self.tagsSearchResults = self.tags.filter({( aTag: String) -> Bool in
            return (aTag.lowercased().range(of: self.searchController.searchBar.text!.lowercased()) != nil)            })
        self.tagsResultsTableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidBeginEditing")
        
        
        self.tagsResultsTableView.alpha = 1.0
        self.tagsResultsTableView.reloadData()
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchTerm = ""
        self.tagsSearchResults = []
        self.tagsResultsTableView.alpha = 0.0
        self.tagsResultsTableView.reloadData()
        self.selectedTag = ""
        self.imageArray.images = []
        self.imageCollectionView?.reloadData()
        getImages()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        
        self.tagsResultsTableView.reloadData()
        
        searchController.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //print("searchBarTextDidEndEditing")
    }
    
    
    
    /////////////// Table Delegate Methods   ///////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        var count:Int!
        count = self.tagsSearchResults.count
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
       
        //print("cell for row tableViewMode = \(self.searchController.tableViewMode)")
        
        
            //print("customer name: \(self.customerNames[indexPath.row])")
            let searchString = self.searchController.searchBar.text!.lowercased()
        
            let cell:TagTableViewCell = tagsResultsTableView.dequeueReusableCell(withIdentifier: "tagCell") as! TagTableViewCell
            
            
            cell.titleLbl.text = self.tagsSearchResults[indexPath.row]
       
        
            //text highlighting
            let baseString:NSString = self.tagsSearchResults[indexPath.row] as NSString
            let highlightedText = NSMutableAttributedString(string: self.tagsSearchResults[indexPath.row])
            var error: NSError?
            let regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: searchString, options: .caseInsensitive)
            } catch let error1 as NSError {
                error = error1
                regex = nil
            }
            if let regexError = error {
                print("Oh no! \(regexError)")
            } else {
                for match in (regex?.matches(in: baseString as String, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: baseString.length)))! as [NSTextCheckingResult] {
                    highlightedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
                }
            }
            cell.titleLbl.attributedText = highlightedText
            
            
            return cell
        
            
            
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            let currentCell = tableView.cellForRow(at: indexPath) as! TagTableViewCell
            self.selectedTag = currentCell.titleLbl.text!
            self.searchController.searchBar.resignFirstResponder()
            self.tagsResultsTableView.alpha = 0.0
        
            self.lazyLoad = 0
            self.limit = 100
            self.offset = 0
            self.batch = 0
            self.imageArray.images = []
        
        
            getImages()
        
        self.searchController.searchBar.text = currentCell.titleLbl.text!
            searchTerm = self.selectedTag
    }
    
    
    
    func willPresentSearchController(_ searchController: UISearchController){
        
        
    }
    
    
    func presentSearchController(searchController: UISearchController){
        
    }

    //refresh functions
    
    @objc func loadData()
    {
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        offset = 0
        batch = 0
        
        imageArray.images = []
        
        
        print("loadData")
        getImages()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher()
    {   print("stopRefresher")
    }

    
    
    
    @objc func addImage(){
        print("Add Image")
        
        
        self.selectedImages.images = []
        self.selectedUIImages = []
        
        
        if(searchController != nil){
            searchController.isActive = false
        }
        
        
        let multiPicker = DKImagePickerController()
        
        multiPicker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
        var selectedAssets = [DKAsset]()
        

       
        multiPicker.showsCancelButton = true
        multiPicker.assetType = .allPhotos
        self.layoutVars.getTopController().present(multiPicker, animated: true) {}
        
        
        
        multiPicker.didSelectAssets = { (assets: [DKAsset]) in
            print("didSelectAssets")
            print(assets)
            
            self.indicator = SDevIndicator.generate(self.view)!
            
            for i in 0..<assets.count
            {
                print("looping images")
                selectedAssets.append(assets[i])
                //print(self.selectedAssets)
                
                
                assets[i].fetchOriginalImage(completeBlock: { image, info in
               
                    
                    print("making image 1")
                                        
                    let imageToAdd = Image2(_id: "0", _fileName: "", _name: "", _width: "200", _height: "200", _description: "", _dateAdded: "", _createdBy: self.appDelegate.defaults.string(forKey: loggedInKeys.loggedInId)!, _type: "")
                    
                   self.selectedImages.images.append(imageToAdd)
                    self.selectedUIImages.append(image!)
                    print("selectedimages count = \(self.selectedImages.images.count)")
                    
                    if self.selectedImages.images.count == assets.count{
                        self.createPrepView()
                    }
                })
            }
            
        }
        
        
        
    }
    
    func createPrepView(){
        print("create prep view")
        
        
       
        
        print("making prep view")
        print("selectedimages count = \(selectedImages.images.count)")
                
        let imageUploadPrepViewController:ImageUploadPrepViewController = ImageUploadPrepViewController(_imageType: "Gallery", _images: selectedImages.images,_uiImages:selectedUIImages)
        
        
        
        print("self.selectedImages.count = \(selectedImages.images.count)")
        
        imageUploadPrepViewController.loadLinkList()
        
        
        
        imageUploadPrepViewController.delegate = self
        
        self.navigationController?.pushViewController(imageUploadPrepViewController, animated: false )
        
        
        self.indicator.dismissIndicator()
        
        
    }
    
    
    @objc func imageSettings(){
        print("image settings")
        
        let imageSettingsViewController = ImageSettingsViewController(_uploadedBy:self.uploadedBy,_portfolio: self.portfolio, _attachment: self.attachment, _task: self.task, _order:self.order, _customer:self.customer)
        imageSettingsViewController.imageSettingsDelegate = self
        navigationController?.pushViewController(imageSettingsViewController, animated: false )
        
        
        
    }
    
    
    func getPrevNextImage(_next:Bool){
        
            if(_next == true){
                if(currentImageIndex + 1) > (self.imageArray.images.count - 1){
                    currentImageIndex = 0
                    imageDetailViewController.image = self.imageArray.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    
                    
                }else{
                    currentImageIndex = currentImageIndex + 1
                    imageDetailViewController.image = self.imageArray.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    
                }
                
            }else{
                if(currentImageIndex - 1) < 0{
                    currentImageIndex = self.imageArray.images.count - 1
                    imageDetailViewController.image = self.imageArray.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                    
                }else{
                    currentImageIndex = currentImageIndex - 1
                    imageDetailViewController.image = self.imageArray.images[currentImageIndex]
                    imageDetailViewController.layoutViews()
                   
                }
            }
            
        
            imageCollectionView?.scrollToItem(at: IndexPath(row: currentImageIndex, section: 0),
                                              at: .top,
                                              animated: false)
       
        

    }

    
    func refreshImages(_images:[Image2]){
        print("refreshImages")
        
        for insertImage in _images{
            
            imageArray.images.insert(insertImage, at: 0)
        }
        
        offset = 0
        batch = 0
        
        shouldShowSearchResults = false
        
        
        imageCollectionView?.reloadData()
        
        imageCollectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
        
        
        
        
        
    }
    
    
   
    
    func showCustomerImages(_customer:String){
        print("show customer images cust: \(_customer)")
        
        self.customer = _customer
        self.imageArray.images = []
        getImages()
        
        
    }
    
    
    
    
    func updateSettings(_uploadedBy:String,_portfolio:String, _attachment:String,_task:String,_order:String,_customer:String){
        print("update settings")
        print("_uploadedBy = \(_uploadedBy) _portfolio = \(_portfolio) _attachment = \(_attachment) _task = \(_task) _order = \(_order) _customer = \(_customer)")
        self.portfolio = _portfolio
        self.attachment = _attachment
        self.task = _task
        self.uploadedBy = _uploadedBy
        self.order = _order
        self.customer = _customer
        
        offset = 0
        batch = 0
        
        for view in self.view.subviews{
            view.removeFromSuperview()
        }
        
        imageArray.images = []
        
        
        getImages()
    }
    
    
    func updateLikes(_index:Int, _liked:String, _likes:String){
        print("update likes _liked: \(_liked)  _likes\(_likes)")
        imageArray.images[_index].liked = _liked
        imageArray.images[_index].likes = _likes
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //print("rotate view")
        
        guard let flowLayout = imageCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            //here you can do the logic for the cell size if phone is in landscape
            //print("landscape")
            portraitMode = false
            
        } else {
            //logic if not landscape
             //print("portrait")
            portraitMode = true
        }
        
        imageCollectionView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50)
        tagsResultsTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 50)
       self.addImageBtn.frame = CGRect(x:0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        
        
        
        flowLayout.invalidateLayout()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.bounds.maxY == scrollView.contentSize.height) {
            print("scrolled to bottom")
            lazyLoad = 1
            batch += 1
            offset = batch * limit
            getImages()
        }
    }
    
    
    
    //restores device to portrait mode when leaving
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        print("view will disappear")
        
         self.imageCollectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        if(searchController != nil){
            searchController.isActive = false
        }
        
        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    func canRotate() -> Void {}
    
    //for No Internet recovery
    func reloadData() {
        self.getTags()
    }
}
