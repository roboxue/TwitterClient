//
//  LoginViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class LoginViewController: TWBaseViewController {
    var _loginButton: UIButton!
    
    override func addSubviews() {
        view.addSubview(loginButton)
    }
    
    override func addLayouts() {
        loginButton.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(view)
        }
    }
}

extension LoginViewController {
    func didPressedLoginButton() {
        TWApi.loginWithCompletion { (user, error) -> Void in
            if let _ = user {
                self.navigationController?.pushViewController(UIViewController(), animated: true)
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
