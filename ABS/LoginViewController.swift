//
//  LoginViewController.swift
//  ABS
//
//  Created by Tobias Steinbrück on 03.07.19.
//  Copyright © 2019 Tobias Steinbrück. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var username: UITextField!
    
    @IBOutlet var password: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        username.placeholder = "Username"
        password.placeholder = "Passwort"
    }
    
    @IBAction func login(_ sender: UIButton) {
        print(username.text!)
        print(password.text!)
    }
    
}
