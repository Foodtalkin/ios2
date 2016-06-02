//
//  UnnamedViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class UnnamedViewController: UIViewController, UITextFieldDelegate, WebServiceCallingDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var btnCheck : UIButton?
    @IBOutlet var txtName : UITextField?
    @IBOutlet var lblAlreadyTakenname : UILabel?
    @IBOutlet var btnCity : UIButton?
    
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
    var arrCityList = NSMutableArray()
    
    var selectedCity = String()
    var typePickerView: UIPickerView = UIPickerView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedCity = "delhi"
        if(isConnectedToNetwork()){
           webServiceForRegion()
        }
        else{
            internetMsg(self.view)
        }

        // Do any additional setup after loading the view.
        self.btnCheck?.enabled = false
        
        lblAlreadyTakenname?.hidden = true
        Flurry.logEvent("Enter Username Screen")
        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UnnamedViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UnnamedViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        self.typePickerView.hidden = true
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)
        self.typePickerView.backgroundColor = UIColor.whiteColor()
        self.typePickerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.typePickerView.layer.borderWidth = 1
        self.view.addSubview(self.typePickerView)
    }
    
    override func viewWillDisappear(animated : Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    @IBAction func moveToNew(sender : UIButton){
        var dictV = NSMutableDictionary()
        dictV = NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails")?.mutableCopy() as! NSMutableDictionary
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken")
        dispatch_async(dispatch_get_main_queue()) {
        dictV.setObject((self.txtName?.text)!, forKey: "userName")
        dictV.setObject(deviceToken!, forKey: "deviceToken")
        dictV.setObject(self.selectedCity, forKey: "region")
        self.webServicecall(dictV)
        }
    }
    
    
    //MARK:- WebService Calling
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForRegion(){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl, "region/", "list")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            
            webServiceCallingPost(url, parameters: params)
            
        }
        else{
            internetMsg(self.view)
        }
        delegate = self
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "region/list"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrCityList = dict.objectForKey("regions") as! NSMutableArray
            }
        }
        else{
        if(dict.objectForKey("status") as! String == "OK"){
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
            self.afterLogindetails(dict)
        }
        else{
           txtName?.text = ""
           btnCheck?.enabled = false
           lblAlreadyTakenname?.hidden = false
        }
        }
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
            NSUserDefaults.standardUserDefaults().setObject(txtName?.text, forKey: "userName")
            
            
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(userId, forKey: "userId")
            currentInstallation.saveInBackground()
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Invite") as! InviteViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else{
            
        }
    }

    
    //MARK:- TextField Delegates
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(range.length + range.location < 16){
        let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.").invertedSet
        let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
        let numberFiltered = compSepByCharInSet.joinWithSeparator("")
        if((range.length + range.location > 3) || (range.length + range.location < 16)){
            btnCheck?.enabled = true
        }
        return string == numberFiltered
        }
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        self.view.frame.origin.y -= 120
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 120
    }

    //MARK:- cityButtonAction
    
    @IBAction func cityButtonTapped(sender : UIButton){
        typePickerView.hidden = false
        typePickerView.reloadAllComponents()
    }
    
    
    //MARK:- pickerView Delegates methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrCityList.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        btnCity?.setTitle((arrCityList.objectAtIndex(row).objectForKey("name") as? String)?.uppercaseString, forState: UIControlState.Normal)
        selectedCity = (arrCityList.objectAtIndex(row).objectForKey("name") as? String)!
        typePickerView.hidden = true
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let view = UIView(frame: CGRectMake(5,0, pickerView.frame.size.width - 10,44))
        let label = UILabel(frame:CGRectMake(5,0, pickerView.frame.size.width - 10, 44))
        label.textAlignment = NSTextAlignment.Center
        view.addSubview(label)
        label.text = (arrCityList.objectAtIndex(row).objectForKey("name") as? String)?.uppercaseString
        return view
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
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
