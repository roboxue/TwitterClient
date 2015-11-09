//
//  TWBaseViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/8/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class TWBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addLayouts()
        initializeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    func addSubviews() {
        
    }
    
    func addLayouts() {
        
    }
    
    func initializeUI() {
        
    }
    
    func refreshUI() {
        
    }

}
