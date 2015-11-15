//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import SwiftSpinner

class LoginViewController: TWBaseViewController {
    private var _loginButton: UIButton!
    var delegate: LoginViewControllerDelegate?
    
    override func addSubviews() {
        view.addSubview(loginButton)
        view.backgroundColor = TWBackgroundColor
    }
    
    override func addLayouts() {
        loginButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(view)
        }
    }
    
    override func refreshUI() {
        if let user = TWApi.currentUser {
            delegate?.UserDidLogIn(user)
        } else if let token = NSUserDefaults.standardUserDefaults().stringForKey(oauthTokenUserDefaultsKey), secret = NSUserDefaults.standardUserDefaults().stringForKey(oauthTokenSecretUserDefaultsKey)  {
            let credential = BDBOAuth1Credential(token: token, secret: secret, expiration: nil)
            SwiftSpinner.show("Recovering user session", animated: true)
            TWApi.recoverUserSession(credential, completion: { (user, error) -> Void in
                if let user = user {
                    SwiftSpinner.hide()
                    self.delegate?.UserDidLogIn(user)
                }
            })
        }
    }
}

extension LoginViewController {
    func didPressedLoginButton() {
        TWApi.loginWithCompletion { (user, error) -> Void in
            if let user = user {
                self.delegate?.UserDidLogIn(user)
            }
        }
    }
}

extension LoginViewController {
    var loginButton: UIButton {
        if _loginButton == nil {
            let v = UIButton(type: .System)
            v.setTitle("Login", forState: .Normal)
            v.addTarget(self, action: "didPressedLoginButton", forControlEvents: .TouchUpInside)
            _loginButton = v
        }
        return _loginButton
    }
}


protocol LoginViewControllerDelegate {
    func UserDidLogIn(user: User)
}