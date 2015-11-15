//
//  MenuViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/14/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit

class MenuViewController: TWBaseViewController {
    private var _tableView: UITableView!
    private var _viewControllers: [UIViewController]!
    private var _loginScreen: LoginViewController!
    private var _homeTimelineScreen: TimelineViewController!

    override func addSubviews() {
        view.addSubview(tableView)
    }
    
    override func addLayouts() {
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.bottom.equalTo(snp_bottomLayoutGuideTop)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
    }
    
    override func initializeUI() {
        if let hamburgerVC = (navigationController ?? self).parentViewController as? TWHamburgerViewController {
            if let _ = TWApi.currentUser {
                hamburgerVC.centerViewController = viewControllers[1]
            } else {
                hamburgerVC.centerViewController = viewControllers[0]
            }
        }
        automaticallyAdjustsScrollViewInsets = false
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let reuseId = "command cell"
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier(reuseId) {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .Default, reuseIdentifier: reuseId)
        }
        switch indexPath.row {
        case 0:
            // Profile cell
            cell.textLabel?.text = "My Profile"
        case 1:
            // Home timeline
            cell.textLabel?.text = "Home"
        default:
            break
        }
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let hamburgerVC = (navigationController ?? self).parentViewController as? TWHamburgerViewController {
            hamburgerVC.centerViewController = viewControllers[indexPath.row]
            hamburgerVC.closeLeftView(true)
        }
    }
}

extension MenuViewController {
    var tableView: UITableView {
        if _tableView == nil {
            let v = UITableView()
            v.dataSource = self
            v.delegate = self
            v.backgroundColor = TWBlue
            v.tableFooterView = UIView()
            _tableView = v
        }
        return _tableView
    }
    
    var viewControllers: [UIViewController] {
        if _viewControllers == nil {
            _viewControllers = [
                loginScreen,
                UINavigationController(rootViewController: homeTimelineScreen)
            ]
        }
        return _viewControllers
    }

    var loginScreen: LoginViewController {
        if _loginScreen == nil {
            _loginScreen = LoginViewController()
        }
        return _loginScreen
    }
    
    var homeTimelineScreen: TimelineViewController {
        if _homeTimelineScreen == nil {
            _homeTimelineScreen = TimelineViewController()
        }
        return _homeTimelineScreen
    }
}