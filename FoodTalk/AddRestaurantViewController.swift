//
//  AddRestaurantViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class AddRestaurantViewController: UIViewController, UITextFieldDelegate, WebServiceCallingDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var txtRestaurantName : UITextField?
    @IBOutlet var txtAddress : UITextField?
    @IBOutlet var moving : UISwitch?
    @IBOutlet var lblImage : UILabel?
    @IBOutlet var lblDescription : UILabel?
    @IBOutlet var viewH : UIView?
    @IBOutlet var addressArea : UILabel?
    @IBOutlet var btnCity : UIButton?
    
    var params = NSMutableDictionary()
    var activeTextField = UITextField()
    
    var arrCityList = NSMutableArray()
    
    var selectedCity = String()
    var typePickerView: UIPickerView = UIPickerView()
    
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var callInt : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedCity = NSUserDefaults.standardUserDefaults().objectForKey("citySelected") as! String
        
        if(isConnectedToNetwork()){
            webServiceForRegion()
        }
        else{
            internetMsg(self.view)
        }

        // Do any additional setup after loading the view.
        self.title = "Add Restaurant"
        Flurry.logEvent("AddRestaurant Screen")
        lblImage?.layer.cornerRadius = 17
        lblImage?.layer.masksToBounds = true
        
        UITextField.appearance().tintColor = UIColor.blackColor()
        
        txtRestaurantName?.keyboardType = UIKeyboardType.ASCIICapable
        txtRestaurantName?.becomeFirstResponder()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "CheckIn", style: .Plain, target: self, action: #selector(AddRestaurantViewController.addTapped))
        self.navigationItem.rightBarButtonItem!.enabled = false;
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddRestaurantViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddRestaurantViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        self.typePickerView.hidden = true
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)
        self.typePickerView.backgroundColor = UIColor.whiteColor()
        self.typePickerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.typePickerView.layer.borderWidth = 1
        self.view.addSubview(self.typePickerView)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        addLocationManager()
    }
    
    override func viewWillDisappear(animated: Bool) {
        cancelRequest()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func isSwitchOnOrOff(sender : UISwitch){
        if(sender.on){
            if(dictLocations.valueForKey("latitude") != nil){
            params = NSMutableDictionary()
            params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            
            self.navigationItem.rightBarButtonItem!.enabled = true;
            
            txtAddress?.text = ""
            txtAddress?.hidden = true
            addressArea?.hidden = true
            viewH?.frame = CGRectMake((viewH?.frame.origin.x)!, (viewH?.frame.origin.y)! - 70, (viewH?.frame.size.width)!, (viewH?.frame.size.height)!)
            lblDescription?.frame = CGRectMake((lblDescription?.frame.origin.x)!, (lblDescription?.frame.origin.y)! - 70, (lblDescription?.frame.size.width)!, (lblDescription?.frame.size.height)!)
            }
            else{
                    let alertController = UIAlertController(
                        title: "Location Disabled",
                        message: "Please enable Location Services in your iPhone Setting to share photos of dishes and where to find them on FoodTalk.'",
                        preferredStyle: .Alert)
                
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                         self.moving?.on = false
                        self.dismissViewControllerAnimated(true, completion: nil)
                       }
                
                    alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
                     if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                        self.moving?.on = false
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(openAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else{
            self.navigationItem.rightBarButtonItem!.enabled = false;
                        
            txtAddress?.hidden = false
            addressArea?.hidden = false
            viewH?.frame = CGRectMake((viewH?.frame.origin.x)!, (viewH?.frame.origin.y)! +
                70, (viewH?.frame.size.width)!, (viewH?.frame.size.height)!)
            lblDescription?.frame = CGRectMake((lblDescription?.frame.origin.x)!, (lblDescription?.frame.origin.y)! +
                70, (lblDescription?.frame.size.width)!, (lblDescription?.frame.size.height)!)
        }
    }
    
    //MARK:- webServiceCall & Delegate
    
    func webServiceCall(){
        var restaurantName = txtRestaurantName?.text
        if (isConnectedToNetwork()){
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerRestaurant, addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            restaurantName = restaurantName!.stringByReplacingOccurrencesOfString("\"", withString: "")
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(restaurantName!, forKey: "restaurantName")
            
            if(txtAddress?.text?.characters.count > 0){
                params.setObject((txtAddress?.text)!, forKey: "address")
                
            }
            params.setObject(selectedCity, forKey: "region")
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
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
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "region/list"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrCityList = dict.objectForKey("regions") as! NSMutableArray
            }
        }
        else{
        if(dict.objectForKey("status") as! String == "OK"){
            restaurantId = dict.objectForKey("restaurantId") as! String
            selectedRestaurantName = (txtRestaurantName?.text)!
            isComingFromDishTag = true
            self.navigationController?.popViewControllerAnimated(true)
//            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("imagePicker") as! XMCCameraViewController;
//            self.navigationController!.pushViewController(openPost, animated:true);
            
        }
        else if(dict.objectForKey("status")!.isEqual("error")){
            if(dict.objectForKey("errorCode")!.isEqual(6)){
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                self.dismissViewControllerAnimated(true, completion: nil)
                
                let nav = (self.navigationController?.viewControllers)! as NSArray
                if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                    for viewController in nav {
                        // some process
                        if viewController.isKindOfClass(LoginViewController) {
                            self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                            break
                        }
                    }
                }
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
        }
        }
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    func addTapped(){
        
        if(txtRestaurantName?.text?.characters.count > 1){
            self.webServiceCall()
        }
    }
    
    
    
    //MARK:- textfield delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count < 2){
            self.navigationItem.rightBarButtonItem!.enabled = false;
        }
        else{
            self.navigationItem.rightBarButtonItem!.enabled = true;
        }
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if(activeTextField == txtAddress){
          self.view.frame.origin.y -= 120
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if(activeTextField == txtAddress){
            
          self.view.frame.origin.y += 120
        }
    }
    
    @IBAction func cityButtonTapped(sender : UIButton){
        txtRestaurantName?.resignFirstResponder()
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
    
    //Location Manager
    
    //MARK:- LocationManager
    func addLocationManager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }
    
    //MARK:- UserLocations Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        dictLocations = NSMutableDictionary()
        dictLocations.setObject(long, forKey: "longitute")
        dictLocations.setObject(lat, forKey: "latitude")
        
        
//        if(callInt == 0){
//            dispatch_async(dispatch_get_main_queue()){
//                self.setUsersClosestCity()
//            }
//            
//        }
//        callInt += 1
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied) {
            self.moving?.on = false
            dictLocations = NSMutableDictionary()
        }
        else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(conectivityMsg)
            // do something with your currentPoint
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
                dispatch_async(dispatch_get_main_queue()) {
                   self.webServiceForRegion()
                }
            }
        }
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
