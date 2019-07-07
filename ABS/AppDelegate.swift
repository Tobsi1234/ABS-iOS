//
//  AppDelegate.swift
//  ABS
//
//  Created by Tobias Steinbrück on 28.06.19.
//  Copyright © 2019 Tobias Steinbrück. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let serverUrl = "http://localhost:8080"
    
    func createAnyRequest(path:String, httpMethod:String = "POST", parameters:[String: String] = [:]) -> URLRequest {
        let url  = URL(string: serverUrl + path)!
        var request = URLRequest(url: url)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        //TODO: parameters not url encoded yet
        request.httpBody = (parameters.compactMap({ (key, value) -> String in return "\(key)=\(value)" }) as Array).joined(separator: "&").data(using: .utf8)
        //print(NSString(data: request.httpBody!, encoding:String.Encoding.utf8.rawValue)!)
        return request
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func checkSessionAndRedirectToCorrectPage() {
        let request = createAnyRequest(path: "/api/session", httpMethod: "POST")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            // set cookies for next request
            let httpRes: HTTPURLResponse = (response as? HTTPURLResponse)!
            let cookies:[HTTPCookie] = HTTPCookie.cookies(withResponseHeaderFields: httpRes.allHeaderFields as! [String : String], for: httpRes.url!)
            HTTPCookieStorage.shared.setCookies(cookies, for: response?.url!, mainDocumentURL: nil)
            
            guard let data = data else {return}
            guard let dataString = String(data: data, encoding: String.Encoding.utf8) else {return}
            let dict = self.convertToDictionary(text: dataString)
            
            // update the UI if all went OK
            DispatchQueue.main.async {
                //print(sessionResult)
                UserDefaults.standard.set(dict?["sessionUser"] ?? "", forKey: "sessionUser")
                UserDefaults.standard.set(dict?["selectedGroup"] ?? "", forKey: "selectedGroup")
                UserDefaults.standard.set(dict?["selectedEvent"] ?? "", forKey: "selectedEvent")
                UserDefaults.standard.set(dict?["selectedEvent"] ?? "", forKey: "selectedEvent")
                
                let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let homeScreen = storyBoard.instantiateViewController(withIdentifier: "TabBarController")
                let loginScreen = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                if(UserDefaults.standard.bool(forKey: "sessionUser")){
                    self.window?.rootViewController = homeScreen
                }else{
                    self.window?.rootViewController = loginScreen
                }
            }
        }
        task.resume()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        checkSessionAndRedirectToCorrectPage()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

