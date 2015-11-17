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
    private var _profileScreen: ProfileViewController!
    private var _homeTimelineScreen: TimelineViewController!
    private var _mentionsTimelineScreen: TimelineViewController!

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
            hamburgerVC.centerViewController = viewControllers[1]
        }
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func refreshUI() {
        if TWApi.userIdentifier == nil {
            presentViewController(LoginViewController(), animated: true, completion: nil)
        }
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
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
        case 2:
            // Home timeline
            cell.textLabel?.text = "Mentions"
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
            hamburgerVC.closeLeftView()
        }
    }
}

extension MenuViewController {
    var tableView: UITableView {
        if _tableView == nil {
            let v = UITableView()
            v.dataSource = self
            v.delegate = self
            v.tableFooterView = UIView()
            _tableView = v
        }
        return _tableView
    }
    
    var viewControllers: [UIViewController] {
        if _viewControllers == nil {
            _viewControllers = [
                MenuEnabledNavigationViewController(rootViewController: profileScreen),
                MenuEnabledNavigationViewController(rootViewController: homeTimelineScreen),
                MenuEnabledNavigationViewController(rootViewController: mentionsTimelineScreen)
            ]
        }
        return _viewControllers
    }

    var profileScreen: ProfileViewController {
        if _profileScreen == nil {
            _profileScreen = ProfileViewController()
            _profileScreen.userId = TWApi.userIdentifier
        }
        return _profileScreen
    }
    
    var homeTimelineScreen: TimelineViewController {
        if _homeTimelineScreen == nil {
            _homeTimelineScreen = TimelineViewController()
            _homeTimelineScreen.source = .Home
        }
        return _homeTimelineScreen
    }

    var mentionsTimelineScreen: TimelineViewController {
        if _mentionsTimelineScreen == nil {
            _mentionsTimelineScreen = TimelineViewController()
            _mentionsTimelineScreen.source = .Mentions
        }
        return _mentionsTimelineScreen
    }
}
