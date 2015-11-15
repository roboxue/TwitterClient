//
//  TWHamburgerViewController.swift
//  TwitterClient
//
//  Created by Robert Xue on 11/14/15.
//  Copyright © 2015 roboxue. All rights reserved.
//

import UIKit
import SnapKit

class TWHamburgerViewController: TWBaseViewController {
    private var _leftView: UIView!
    private var _centerView: UIView!
    private var _panGR: UIPanGestureRecognizer!
    private let leftViewWidthRatio = 0.8
    
    var originalLeftMargin: CGFloat!
    var leftViewRightConstraint: Constraint!
    var centerViewController: UIViewController! {
        didSet {
            if let oldController = oldValue {
                if oldController == centerViewController {
                    return
                } else {
                    oldController.view.removeFromSuperview()
                }
            }
            centerViewController.willMoveToParentViewController(self)
            centerView.addSubview(centerViewController.view)
            addChildViewController(centerViewController)
            centerViewController.view.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(centerView)
            }
            centerViewController.didMoveToParentViewController(self)
        }
    }
    
    var leftViewController: UIViewController! {
        didSet {
            if let oldController = oldValue {
                oldController.willMoveToParentViewController(nil)
                oldController.view.removeFromSuperview()
                oldController.removeFromParentViewController()
            }
            leftViewController.willMoveToParentViewController(self)
            addChildViewController(leftViewController)
            leftView.addSubview(leftViewController.view)
            leftViewController.view.snp_makeConstraints { (make) -> Void in
                make.edges.equalTo(leftView)
            }
            leftViewController.didMoveToParentViewController(self)
        }
    }

    override func addSubviews() {
        view.addSubview(centerView)
        view.addSubview(leftView)
    }
    
    override func addLayouts() {
        leftView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view)
            make.bottom.equalTo(view)
            self.leftViewRightConstraint = make.right.equalTo(view.snp_left).constraint
            make.width.equalTo(view).multipliedBy(leftViewWidthRatio)
        }
        centerView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
            make.width.equalTo(view)
        }
    }
}

extension TWHamburgerViewController {
    func onPan(source: UIPanGestureRecognizer) {
        let translation = source.translationInView(view)
        let velocity = source.velocityInView(view)
        
        switch source.state {
        case .Began:
            originalLeftMargin = leftView.frame.origin.x + leftView.frame.width
        case .Changed:
            leftViewRightConstraint.updateOffset(translation.x + originalLeftMargin)
        case .Ended:
            if velocity.x > 0 {
                openLeftView(true)
            } else {
                closeLeftView(true)
            }
        default:
            break
        }
    }
    
    func closeLeftView(animated: Bool) {
        let handler = { () -> Void in
            self.leftViewRightConstraint.updateOffset(0)
            self.leftView.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.5, animations: handler)
        } else {
            handler()
        }
    }
    
    func openLeftView(animated: Bool) {
        let handler = { () -> Void in
            self.leftViewRightConstraint.updateOffset(self.view.frame.size.width * CGFloat(self.leftViewWidthRatio))
            self.leftView.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.5, animations: handler)
        } else {
            handler()
        }
    }
}

extension TWHamburgerViewController {
    var leftView: UIView {
        if _leftView == nil {
            let v = UIView()
            _leftView = v
        }
        return _leftView
    }
    
    var centerView: UIView {
        if _centerView == nil {
            let v = UIView()
            v.addGestureRecognizer(panGR)
            _centerView = v
        }
        return _centerView
    }
    
    var panGR: UIPanGestureRecognizer {
        if _panGR == nil {
            let gr = UIPanGestureRecognizer(target: self, action: "onPan:")
            _panGR = gr
        }
        return _panGR
    }
}
