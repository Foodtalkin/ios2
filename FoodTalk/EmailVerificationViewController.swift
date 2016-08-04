//
//  EmailVerificationViewController.swift
//  FoodTalk
//
//  Created by Ashish on 29/04/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class EmailVerificationViewController: UIViewController, UITextFieldDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var txtEmail : UITextField?
    @IBOutlet var btnSubmit : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        // Do any additional setup after loading the view.
        txtEmail?.autocorrectionType = UITextAutocorrectionType.No
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EmailVerificationViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EmailVerificationViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewDidAppear(animated: Bool) {
        txtEmail?.becomeFirstResponder()
        self.view.frame.origin.y -= 90
    }
    
    override func viewWillDisappear(animated : Bool) {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        self.view.frame.origin.y += 90
    }
    
    @IBAction func submitClick(sender : UIButton){
        if(txtEmail?.text?.characters.count > 0){
            if(isValidEmail((txtEmail?.text)!)){
               let dictEmailValue = NSUserDefaults.standardUserDefaults().objectForKey("emailVerifyValue")?.mutableCopy() as! NSMutableDictionary
                dictEmailValue.setObject((txtEmail?.text)!, forKey: "email")
                
                self.webServicecall(dictEmailValue)
            }
            else{
                let alertView = UIAlertView(title: "Please enter a valid email.", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
        }
        else{
            
        }
    }
    
    //MARK:- Calling WebServices
    
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork() == true){
            let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
            webServiceCallingPost(url, parameters: params)
            loginAllDetails = params
            NSUserDefaults.standardUserDefaults().setObject(loginAllDetails, forKey: "AllLogindetails")
            delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("profile")?.intValue != 0){
        let strChannel = dict.objectForKey("profile")?.objectForKey("channels") as! String
        let channelArray = strChannel.componentsSeparatedByString(",")
        
        NSUserDefaults.standardUserDefaults().setObject(channelArray, forKey: "channels")
        }
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
        self.afterLogindetails(dict)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    
    //MARK:- Additional Action After Login
    
    func afterLogindetails(infoDict : NSDictionary){
        
        if(infoDict.objectForKey("status")!.isEqual("OK")){
            
            let sessionId = infoDict.objectForKey("sessionId") as! String
            let userId = infoDict.objectForKey("userId") as! String
            NSUserDefaults.standardUserDefaults().setObject(sessionId, forKey: "sessionId")
            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
            
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(userId, forKey: "userId")
            currentInstallation.saveInBackground()
            
            if(infoDict.objectForKey("isNewUser")?.intValue != 0){
                let searchScreen = self.storyboard!.instantiateViewControllerWithIdentifier("Unnamed") as! UnnamedViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(searchScreen, animated:true);
            }
            else{
                let username = infoDict.objectForKey("userName")
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "userName")
                var tbc : UITabBarController
                tbc = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController;
                tbc.selectedIndex=0;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(tbc, animated:true);
            }
        }
        else{
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
     //   textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 90
    }
    
    func keyboardWillHide(sender: NSNotification) {
     //   self.view.frame.origin.y += 120
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
