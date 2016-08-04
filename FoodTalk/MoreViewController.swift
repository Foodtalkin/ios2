//
//  MoreViewController.swift
//  FoodTalk
//
//  Created by Ashish on 21/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var eventName = String()
var isSuggestion : Bool = false

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate, UITabBarControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableView : UITableView?
    var moreArray : NSMutableArray = []
    
    var dict = NSDictionary()
    var refreshControl:UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
     //   self.tabBarController?.tabBar.userInteractionEnabled = false
        
        dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        
        moreArray.addObject((dict.objectForKey("profile")?.objectForKey("userName") as? String)!)
        moreArray.addObject("Food Talk Curated")
        moreArray.addObject("Delhi-NCR")
        moreArray.addObject("Bucket List")
        moreArray.addObject("Options")
        moreArray.addObject("Find facebook friends")
  
        
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = UIColor.grayColor()
        
        self.refreshControl.addTarget(self, action: #selector(MoreViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl)

        Flurry.logEvent("More Screen")
      //  self.title = "More"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
   //     tableView!.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 45/255, alpha: 1.0)
        tableView?.backgroundColor = UIColor.whiteColor()
        tableView?.separatorColor = UIColor.lightGrayColor()
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
    }
    
    //MARK:- RefreshControl Method
    func refresh(sender:AnyObject)
    {
        moreArray = NSMutableArray()
        moreArray.addObject((dict.objectForKey("profile")?.objectForKey("userName") as? String)!)
        moreArray.addObject("Food Talk Curated")
        moreArray.addObject("Delhi-NCR")
        moreArray.addObject("Bucket List")
        moreArray.addObject("Options")
        moreArray.addObject("Find facebook friends")
//        moreArray.addObject("Events and contests")
        dispatch_async(dispatch_get_main_queue()) {
//        self.webServiceCallForEvents()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        selectedTabBarIndex = 4
        self.refreshControl.endRefreshing()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        cancelRequest()
        self.refreshControl.endRefreshing()
        super.viewWillDisappear(animated)
    }
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        self.addViewsOnCell(cell, index: indexPath.row)
        if(indexPath.row == 4){
//            cell.backgroundColor = UIColor.blackColor()
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.backgroundColor = UIColor.whiteColor()
            if(moreArray.count > 0){
         //   cell.textLabel?.text = moreArray.objectAtIndex(indexPath.row) as? String
            }
        }
        else{
            cell.backgroundColor = UIColor.whiteColor()
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 4){
            return 58
        }
        return 58
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.row == 0){
            isUserInfo = true
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(indexPath.row == 1){
            isSuggestion = true
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("foodTalkSugges") as! FoodTalkSuggestionsViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
       
        else if(indexPath.row == 3){

            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Favorite") as! FavoriteViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(indexPath.row == 4){

            
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Options") as! OptionsViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(indexPath.row == 2){
            
        }
        else if(indexPath.row == 5){
            
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("facebookFriends") as! FacebookFriendsViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else{
            if(isConnectedToNetwork()){
                webViewCallingLegal = false
                if(self.moreArray.count > 0){
            eventName = (self.moreArray.objectAtIndex(indexPath.row).objectForKey("name") as? String)!
            webViewLink = self.moreArray.objectAtIndex(indexPath.row).objectForKey("url") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("WebLink") as! WebLinkViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
        
    }
    
    func addViewsOnCell(cell : UITableViewCell, index : Int){
        
            
        if(index == 0){
                let imgView = UIImageView()
                imgView.frame = CGRectMake(18, 9, 40, 40)
                imgView.contentMode = UIViewContentMode.ScaleAspectFit
            
                imgView.hnk_setImageFromURL(NSURL(string: (dict.objectForKey("profile")?.objectForKey("thumb") as? String)!)!)
                imgView.layer.cornerRadius = 20
                imgView.layer.masksToBounds = true
                cell.contentView.addSubview(imgView)
        }
        else{
            
        let optionIcon = UIImageView()
        let optionViewBook = UIView()
        let imgBookMark = UIImageView()
            imgBookMark.tag = 232323
            
                if(index == 2){
                optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                optionViewBook.backgroundColor = UIColor(red: 28/255, green: 103/255, blue: 204/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                imgBookMark.image = UIImage(named: "location.png")
                optionViewBook.addSubview(imgBookMark)
                }
                else if(index == 3){
                    optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                    optionViewBook.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 10/255, alpha: 1.0)
                    optionViewBook.layer.cornerRadius = 20
                    optionIcon.layer.masksToBounds = true
                    cell.contentView.addSubview(optionViewBook)
                    
                    imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                    imgBookMark.image = UIImage(named: "bookmark (1).png")
                    optionViewBook.addSubview(imgBookMark)
                }
                else if(index == 4){
                    optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                    optionViewBook.backgroundColor = UIColor(red: 65/255, green: 87/255, blue: 148/255, alpha: 1.0)
                    optionViewBook.layer.cornerRadius = 20
                    optionIcon.layer.masksToBounds = true
                    cell.contentView.addSubview(optionViewBook)
                    
                    imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                    imgBookMark.image = UIImage(named: "settings.png")
                    optionViewBook.addSubview(imgBookMark)
                }
                else if(index == 5){
                    optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                    optionViewBook.backgroundColor = UIColor(red: 65/255, green: 87/255, blue: 148/255, alpha: 1.0)
                    optionViewBook.layer.cornerRadius = 20
                    optionIcon.layer.masksToBounds = true
                    cell.contentView.addSubview(optionViewBook)
                    
                    imgBookMark.frame = CGRectMake(7, 8, 20, 20)
                    imgBookMark.image = UIImage(named: "fb-logo.png")
                    optionViewBook.addSubview(imgBookMark)
                }
                else if(index == 1){
                    optionViewBook.frame = CGRectMake(18, 9, 40, 40)
                    optionViewBook.backgroundColor = UIColor.redColor()
                    optionViewBook.layer.cornerRadius = 20
                    optionIcon.layer.masksToBounds = true
                    cell.contentView.addSubview(optionViewBook)
                    
                    imgBookMark.frame = CGRectMake(10, 10, 20, 20)
                    imgBookMark.image = UIImage(named: "likeIcon.png")
                    
                    if((cell.contentView.viewWithTag(232323)) != nil){
                        cell.contentView.viewWithTag(232323)?.removeFromSuperview()
                    }
                    optionViewBook.addSubview(imgBookMark)
                }

            
        
        }
            
        if(index == 0){
           let statuslabel = UILabel()
           statuslabel.frame = CGRectMake(74, 8, UIScreen.mainScreen().bounds.size.width - 128, 20)
           statuslabel.textColor = UIColor.blackColor()
           statuslabel.numberOfLines = 0
           statuslabel.font = UIFont(name:fontName, size: 16.0)
            if(moreArray.count > 0){
           statuslabel.text = moreArray.objectAtIndex(index) as? String
            }
           cell.contentView.addSubview(statuslabel)
            
            let statuslabel1 = UILabel()
            statuslabel1.frame = CGRectMake(74, 30, UIScreen.mainScreen().bounds.size.width - 128, 20)
            statuslabel1.textColor = UIColor.grayColor()
            statuslabel1.font = UIFont(name:fontName, size: 15.0)
            statuslabel1.numberOfLines = 0
            statuslabel1.text = (dict.objectForKey("profile")?.objectForKey("fullName") as? String)!
            cell.contentView.addSubview(statuslabel1)
            
        }
        else{
            let statuslabel = UILabel()
            statuslabel.tag = 3333
            statuslabel.frame = CGRectMake(74, 0, UIScreen.mainScreen().bounds.size.width - 128, 58)
            if(index == 2){
            
                statuslabel.text = (dict.objectForKey("profile")?.objectForKey("region") as? String)!
                statuslabel.textColor = UIColor.grayColor()
            }
            else{
               statuslabel.textColor = UIColor.blackColor()
            }
            
            statuslabel.numberOfLines = 0
            statuslabel.font = UIFont(name:fontName, size: 18.0)
            if(index < 7){
                if(index != 2){
            statuslabel.text = moreArray.objectAtIndex(index) as? String
                }
            }
            else{
                if(moreArray.count > 0){
                if(moreArray.count > 5){
            statuslabel.text = moreArray.objectAtIndex(index).objectForKey("name") as? String
                }
                }
            }
            if((cell.contentView.viewWithTag(3333)) != nil){
                cell.contentView.viewWithTag(3333)?.removeFromSuperview()
            }
            cell.contentView.addSubview(statuslabel)
            }
    }
    
    //MARK:- CallWebServiceForEvents
    
    func webServiceCallForEvents(){
        if (isConnectedToNetwork()){
            
            let url = "http://api.foodtalkindia.com/getfeeds"
            
            webServiceGet(url)
            delegate = self
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
            self.refreshControl.endRefreshing()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        self.refreshControl.endRefreshing()
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        if((dict.objectForKey("code")) != nil){
        if(dict.objectForKey("code") as! String == "200"){
            var arr = NSArray()
            arr = dict.objectForKey("result")?.objectForKey("data") as! NSArray
            for(var index : Int = 0; index < arr.count; index += 1){
                moreArray.addObject(arr.objectAtIndex(index))
            }
        }
        }

        self.tabBarController?.tabBar.userInteractionEnabled = true
        
        tableView?.reloadData()
        self.refreshControl.endRefreshing()
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- TabBarController Delegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        self.navigationController?.popToRootViewControllerAnimated(false)
        selectedTabBarIndex = 4
    }
    
    //MARK:- stop back gesture
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
