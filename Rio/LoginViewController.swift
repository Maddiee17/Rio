//
//  LoginViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 07/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit


let kBaseLoginURL = "http://ec2-52-37-90-104.us-west-2.compute.amazonaws.com/olympics-scheduler/user/%@"



class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    var userDataDict : NSDictionary?
    var dataBaseManager = RioDatabaseInteractor()
    var wsManager = WSManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        let fbButton = FBSDKLoginButton()
        fbButton.readPermissions = ["public_profile", "email"]
        fbButton.delegate = self
        fbButton.frame = CGRectMake(self.view.center.x-100, self.view.center.y, 193, 40)
        self.view.addSubview(fbButton)
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        let googleButton = GIDSignInButton(frame: CGRectMake(self.view.center.x - 103 ,self.view.center.y + 8 + fbButton.frame.size.height ,0,0))
        googleButton.style = .Wide
        self.view.addSubview(googleButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - FB Delegates


    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            KVNProgress.showWithStatus("Logging you in..")
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            FBSDKGraphRequest(graphPath: "\(result.token.userID)", parameters: ["fields" : "id,first_name,last_name,email,gender,picture,timezone"], HTTPMethod: "GET").startWithCompletionHandler({ (connection, result, error) -> Void in
                
                if (error == nil) {
                    if(Reachability.isConnectedToNetwork()){
                        self.completeLoginCalls(result as! Dictionary<String, AnyObject>, isFacebookLogin: true)
                    }
                    else{
                        RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
                    }
                }
            })
        }
    }
    
//    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
//        if Reachability.isConnectedToNetwork() {
//            return true
//        }
//        else{
//            //RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
//            return false
//        }
//    }
    
    
    // MARK: - Google Delegates
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                KVNProgress.showWithStatus("Logging you in..")
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                // Perform any operations on signed in user here.
                let userId = user.userID                  // For client-side use only!
                //                let idToken = user.authentication.idToken // Safe to send to the server
                let fullName = user.profile.name
                let email = user.profile.email
                let hasImage = user.profile.hasImage
                var profileImage = NSURL(string: "")
                if(hasImage){
                    profileImage = user.profile.imageURLWithDimension(150)
                }
                let userDict = ["emailId":email, "photoUrl":profileImage?.absoluteString, "name":fullName, "id":userId]
                self.completeLoginCalls(userDict,isFacebookLogin: false)
            } else {
                print("\(error.localizedDescription)")
            }
    }

    // MARK: - Service Calls to AWS

    
    func completeLoginCalls(result:Dictionary<String,AnyObject>, isFacebookLogin:Bool){
        
        KVNProgress.showWithStatus("Hold on...")

        var paramsDict : NSDictionary?
        var data : NSData?
        let notificationId = NSUserDefaults.standardUserDefaults().stringForKey("notificationId") ?? ""
        var email : String?
        
        if(isFacebookLogin){
            email = (result as NSDictionary).objectForKey("email") as? String
            let name = (result as NSDictionary).objectForKey("first_name")
            let id = (result as NSDictionary).objectForKey("id")
            let photoDict = (result as NSDictionary).objectForKey("picture") as! NSDictionary
            let dataDict = photoDict.objectForKey("data") as! NSDictionary
            let finalUrl = dataDict.objectForKey("url")
            paramsDict = ["emailId" : email!, "name" : name!, "facebookId" :id!, "photoUrl" : finalUrl!, "notificationId" :notificationId, "advanceNotificationTime" : "0000000"] as NSDictionary
        }
        else {
            email = (result as NSDictionary).objectForKey("emailId") as? String
            let name = (result as NSDictionary).objectForKey("name")
            let id = (result as NSDictionary).objectForKey("id")
            let photoURL = (result as NSDictionary).objectForKey("photoUrl")
            paramsDict = ["emailId" : email!, "name" : name!, "googleId" :id!, "photoUrl" : photoURL!, "notificationId" :notificationId, "advanceNotificationTime" : "0000000"] as NSDictionary
        }
        do{
            data = try NSJSONSerialization.dataWithJSONObject(paramsDict!, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch{
            print("JSON error")
        }
        var endPointUrl : String?
        if(isFacebookLogin){
            endPointUrl = String(format: kBaseLoginURL, "facebookOauthLogin")
        }
        else {
            endPointUrl = String(format: kBaseLoginURL, "googleOauthLogin")
        }
        let url = NSURL(string: endPointUrl!)
        let urlRequest = NSMutableURLRequest(URL: url!)
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.HTTPBody = data!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, response , error) -> Void in
            if(error == nil){
                print(response)
                self.getDictFromData(data!)
                let responseDict = self.userDataDict?.objectForKey("response") as! NSDictionary
                if (responseDict.objectForKey("statusCode") as! Int == 200){
                    self.updateDBWithData()
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.navigateToProfile()
                    })
                }
                else{
                    KVNProgress.showErrorWithStatus("Login Failed")
                }
            }
            else {
                print("got Error",error)
                KVNProgress.showWithStatus("Error while logging in")
            }
        }
        task.resume()
        
    }
    
    // MARK: - Handling UI Changes

    func navigateToProfile()
    {
        KVNProgress.dismiss()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.performSegueWithIdentifier("profileSegue", sender: self)
    }
    
    func updateDBWithData()
    {
        dataBaseManager.insertUserProfileValues(userDataDict!)
    }
    
    func getDictFromData(data:NSData)
    {
        do{
            userDataDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            NSUserDefaults.standardUserDefaults().setObject(userDataDict!.objectForKey("userId"), forKey: "userId")
            NSUserDefaults.standardUserDefaults().synchronize()

        }
        catch{
            let strData = String(data: data, encoding: NSUTF8StringEncoding)
            print(strData)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "profileSegue"){
            let profileViewController = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! UserProfileViewController
            profileViewController.userDataDict = self.userDataDict
        }
    }
    
    @IBAction func skipLoginTapped(sender: UIButton)
    {
        var paramsDict : NSDictionary?
        let notificationId = NSUserDefaults.standardUserDefaults().stringForKey("notificationId") ?? ""
        
        if NSUserDefaults.standardUserDefaults().objectForKey("guestEmail") == nil {
            NSUserDefaults.standardUserDefaults().setObject(NSUUID().UUIDString, forKey: "guestEmail")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        paramsDict = ["emailId" :  NSUserDefaults.standardUserDefaults().objectForKey("guestEmail")!, "name" : "Guest", "facebookId" :"", "googleId" : "","photoUrl" : "", "notificationId" :notificationId, "advanceNotificationTime" : "0000000"] as NSDictionary
        
        let endPointUrl = String(format: kBaseLoginURL, "facebookOauthLogin")
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: endPointUrl)!)
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.HTTPBody = RioUtilities.sharedInstance.convertDictToData(paramsDict!)
        
        if Reachability.isConnectedToNetwork() {
            
            KVNProgress.showWithStatus("Creating Guest Account...")
            NSUserDefaults.standardUserDefaults().setObject("true", forKey: "isGuest")
            NSUserDefaults.standardUserDefaults().synchronize()
            self.wsManager.performURLSessionForTaskForRequest(urlRequest, successBlock: { (responseData) in
                print(responseData)
                self.getDictFromData(responseData as! NSData)
                let responseDict = self.userDataDict?.objectForKey("response") as! NSDictionary
                if (responseDict.objectForKey("statusCode") as! Int == 200){
                    self.updateDBWithData()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigateToProfile()
                    })
                }
                
            }) { (error) in
                print(error)
            }
        }
        RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
    }

}
