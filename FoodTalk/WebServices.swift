//
//  WebServices.swift
//  FoodTalk
//
//  Created by Ashish on 08/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SystemConfiguration

var baseUrl = "http://52.74.136.146/index.php/service/"
//var baseUrl = "http://52.74.136.146/index.php/service/"

var conectivityMsg = UIView()

var controllerAuth = "auth/"
var controllerPost = "post/"
var controllerUser = "user/"
var controllerRestaurant = "restaurant/"
var controllerLike = "like/"
var controllerComment = "comment/"
var controllerFollowers = "follower/"
var controllerFlag = "flag/"
var controllerTag = "tag/"
var controllerNotification = "notification/"
var controllerRestaurantSuggestion = "restaurantSuggestion/"
var controllerProblem = "problem/"
var controllerContactUs = "contactUs/"
var controllerUsers = "user/"
var controllerDish = "dish/"
var controllerRestaurentReport = "restaurantReport/"
var controllerBookmark = "bookmark/"


var signinMethod = "signin"
var getprofileMethod = "getProfile"
var updateProfileMethod = "updateProfile"
var updateSettingMethod = "updateSetting"
var updatecuisinemthod = "updateCuisine"
var searchListMethod = "list"
var logoutMethod = "logout"
var resetBadgeMethod = "resetBadge"
var postCreateMethod = "create"
var postListMethod = "list"
var getRestaurantProfileMethod = "getProfile"
var restaurantListMethod = "list"
var addlikeMethod = "add"
var listByPostMethod = "listByPost"
var deleteLikeMethod = "delete"
var commentAddMethod = "add"
var commentListMethod = "list"
var commentDeleteMethod = "delete"
var followMethod = "follow"
var unfollowMethod = "unfollow"
var addFlagMethod = "add"
var flagListMethod = "listByPost"
var getImageCheckinPost = "getImageCheckInPosts"
var suggestionMethod = "suggestions"
var followBulkMethod = "followBulk"
var getUserByFbMethod = "getUsersByFacebookIds"
var listFollowersMethod = "listFollowers"
var restaurentListMethod = "listName"
var follwedlist = "listFollowed"
var userListNames = "listNames"
var getTippostsMethod = "getTipPosts"
var getRestaurantimagepostMethod = "getImagePosts"
var getCheckInPostsMethod = "getCheckInPosts"
var cloudAccessMethod = "cloudaccess"
var searchMethod = "search"

var fontBold = "Helvetica-Bold"
var fontName = "Helvetica"

var cloudName = "digital-food-talk-pvt-ltd"
var cloudAPIKey = "849964931992422"
var cloudsecretKey = "_xG26XxqmqCVcpl0l9-5TJs77Qc"

var overlayView = UIView()
var activityIndicator = UIActivityIndicatorView()

var userLoginAllInfo = NSMutableDictionary()
var homeListInfo = NSMutableDictionary()

var isUserInfo = Bool()

func loadImageAndCache(imageView : UIImageView, url : String){
    Alamofire.request(.GET, url).response() {
        (_, _, data, _) in
        
        let image = UIImage(data: data!)
        imageView.image = image
    }
}

func showLoader(view : UIView){
    if (view.viewWithTag(44) == nil) {
    overlayView = UIView()
    activityIndicator = UIActivityIndicatorView()
    overlayView.frame = CGRectMake(view.frame.size.width/2 - 40, view.frame.size.height/2 - 40, 80, 80)
    overlayView.backgroundColor = UIColor.clearColor()
    overlayView.tag = 44
    overlayView.clipsToBounds = true
    overlayView.layer.cornerRadius = 10
    overlayView.layer.zPosition = 1
    
    activityIndicator.frame = CGRectMake(0, 0, 40, 40)
    activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
    activityIndicator.activityIndicatorViewStyle = .Gray
    overlayView.addSubview(activityIndicator)
    
    view.addSubview(overlayView)
    view.userInteractionEnabled = false
    activityIndicator.startAnimating()
    }
}

func showColorLoader(view : UIView){
    if (view.viewWithTag(44) == nil) {
        overlayView = UIView()
        activityIndicator = UIActivityIndicatorView()
        overlayView.frame = CGRectMake(view.frame.size.width/2 - 40, view.frame.size.height/2 - 40, 80, 80)
        overlayView.backgroundColor = UIColor.clearColor()
        overlayView.tag = 44
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.layer.zPosition = 1
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)
    //    activityIndicator.activityIndicatorViewStyle = .Gray
        activityIndicator.color = UIColor.blackColor()
        overlayView.addSubview(activityIndicator)
        
        view.addSubview(overlayView)
        view.userInteractionEnabled = false
        activityIndicator.startAnimating()
    }
}

func toBase64(str : String)->String{
    
    let plainData = (str as
        NSString).dataUsingEncoding(NSUTF8StringEncoding)
    let base64String = plainData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    return base64String
    
}

func isConnectedToNetwork()->Bool{
    
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }) else {
        return false
    }
    
    var flags : SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
        return false
    }
    
    let isReachable = flags.contains(.Reachable)
    let needsConnection = flags.contains(.ConnectionRequired)
    return (isReachable && !needsConnection)
}

func internetMsg(view : UIView){
    
    conectivityMsg.frame = CGRectMake(0, 64, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - 108)
    conectivityMsg.tag = 112233
    conectivityMsg.userInteractionEnabled = true
    conectivityMsg.backgroundColor = UIColor.whiteColor()
   
   
    let imgWifi = UIImageView()
    imgWifi.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2 - 24, UIScreen.mainScreen().bounds.size.height/2 - 98, 48, 48)
    imgWifi.image = UIImage(named: "wifi.png")
    conectivityMsg.addSubview(imgWifi)
    
    let lblMsg = UILabel()
    lblMsg.frame = CGRectMake(50, imgWifi.frame.origin.y + imgWifi.frame.size.height, view.frame.size.width - 100, 60)
    lblMsg.text = "Cannot connect to internet. Tap to retry."
    lblMsg.textColor = UIColor.grayColor()
    lblMsg.textAlignment = NSTextAlignment.Center
    lblMsg.numberOfLines = 2
    conectivityMsg.addSubview(lblMsg)
    
    view.addSubview(conectivityMsg)
}

func differenceDate(dateString : String) -> String {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let date = dateFormatter.dateFromString(dateString)
    
    dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+5:30");
    let todayCurrent = dateFormatter.stringFromDate(NSDate())
    let dateCurrent = dateFormatter.dateFromString(todayCurrent)
    
    var diffrenceDates = ""
    
    let start = date
    let calendar = NSCalendar.currentCalendar()
    
    let datecomponenetsHour = calendar.components(.Hour, fromDate: start!, toDate: dateCurrent!, options: [])
    let hour = datecomponenetsHour.hour
    
    let datecomponenetsYear = calendar.components(.Year, fromDate: start!, toDate: NSDate(), options: [])
    let year = datecomponenetsYear.year
    
    let datecomponenetsDay = calendar.components(.Day, fromDate: start!, toDate: NSDate(), options: [])
    let day = datecomponenetsDay.day
    
    let datecomponenetsSeconds = calendar.components(.Second, fromDate: start!, toDate: dateCurrent!, options: [])
    let seconds = datecomponenetsSeconds.second
    
    let datecomponenetsMinute = calendar.components(.Minute, fromDate: start!, toDate: dateCurrent!, options: [])
    let minute = datecomponenetsMinute.minute
    
    if(year > 1){
       let noOfYears = year
        diffrenceDates = String(format: "%dY", noOfYears)
    }
    else{
        
       if(seconds < 60){
          let noOfseconds = seconds
          diffrenceDates = String(format: "%ds", noOfseconds)
       }
       else if(minute < 60){
        let minutesNumber = minute
        diffrenceDates = String(format: "%dm", minutesNumber)
       }
       else if(hour < 24){
        let hurnumber = hour
        diffrenceDates = String(format: "%dh", hurnumber)
       }
       else if(day < 7){
        let numberOfDays = day
        diffrenceDates = String(format: "%dd", numberOfDays)
       }
       else{
        let noOfWeeks = day/7
        diffrenceDates = String(format: "%dw", noOfWeeks)
        }
    }
    
    return diffrenceDates
    
}

func isValidEmail(testStr:String) -> Bool {
    // println("validate calendar: \(testStr)")
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(testStr)
}

func stopLoading1(view : UIView){
    
    for subViews in view.subviews {
        if(subViews == overlayView){
        overlayView.removeFromSuperview()
        }
    }
    for subViews in view.subviews {
        if(subViews == activityIndicator){
            activityIndicator.removeFromSuperview()
        }
    }
    view.userInteractionEnabled = true
}

func stopLoading(view : UIView){
    overlayView.removeFromSuperview()
    activityIndicator.stopAnimating()
   view.userInteractionEnabled = true
}

func showProcessLoder(view : UIView){
    let bottomView = UIView()
    bottomView.frame = CGRectMake(0, view.frame.size.height - 94, view.frame.size.width, 50)
    bottomView.backgroundColor = UIColor.whiteColor()
    bottomView.tag = 2222
    //view.addSubview(bottomView)
    
    let activityIndicator1 = UIActivityIndicatorView()
    activityIndicator1.frame = CGRectMake(0, 0, 40, 40)
    activityIndicator1.tag = 2223
    activityIndicator1.center = CGPointMake(bottomView.bounds.width / 2, bottomView.bounds.height / 2)
    activityIndicator1.activityIndicatorViewStyle = .Gray
    bottomView.addSubview(activityIndicator1)
    view.addSubview(bottomView)
    activityIndicator1.startAnimating()
}

func hideProcessLoader(view : UIView){
    for subViews in view.subviews {
        if(subViews.tag == 2222){
            subViews.removeFromSuperview()
        }
    }
    for subViews in view.subviews {
        if(subViews.tag == 2223){
            subViews.removeFromSuperview()
        }
    }
}


func appdelegate() -> AppDelegate{
     return  UIApplication.sharedApplication().delegate as! AppDelegate
}

