//
//  MenuEnabledNavigationViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/17/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class MenuEnabledNavigationViewController: UINavigationController {

    private var _menuBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if topViewController == self.viewControllers[0] {
            topViewController!.navigationItem.leftBarButtonItem = menuBarButton
        }
    }

    var menuBarButton: UIBarButtonItem {
        if _menuBarButton == nil {
            let v = UIBarButtonItem(image: UIImage(named: "Settings"), style: .Plain, target: self.navigationController?.parentViewController, action: "toggle")
            _menuBarButton = v
        }
        return _menuBarButton
    }
}
