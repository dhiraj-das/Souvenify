//
//  SideBar.swift
//  Souvenify
//
//  Created by Dhiraj Das on 8/31/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import UIKit
import FirebaseAuth

@objc protocol SideBarDelegate{
    func sideBarDidSelectButtonAtIndex(index:Int, section: Int)
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate, UIGestureRecognizerDelegate {
    
    let barWidth:CGFloat = 250.0
    let sideBarTableViewTopInset:CGFloat = 64.0
    let sideBarContainerView:UIView = UIView()
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    var originView:UIView = UIView()
    
    var animator:UIDynamicAnimator!
    var delegate:SideBarDelegate?
    var isSideBarOpen:Bool = false
    var firAuthUser : FIRAuth!
    
    override init() {
        super.init()
    }
    
    init(sourceView:UIView, menuItems:Array<String>, user: FIRAuth!){
        super.init()
        originView = sourceView
        firAuthUser = user
        sideBarTableViewController.tableData = menuItems
        
        setupSideBar()
        
        animator = UIDynamicAnimator(referenceView: originView)
        
        let showGestureRecognizer:UIScreenEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(SideBar.handleSwipe))
        showGestureRecognizer.edges = .Left
        originView.addGestureRecognizer(showGestureRecognizer)
        
        let hideGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SideBar.handleTap))
        hideGestureRecognizer.delegate = self
        originView.addGestureRecognizer(hideGestureRecognizer)
        
    }
    
    
    func setupSideBar(){
        
        sideBarContainerView.frame = CGRectMake(-barWidth - 1, originView.frame.origin.y, barWidth, originView.frame.size.height)
        sideBarContainerView.backgroundColor = UIColor.clearColor()
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        
        let blurView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        blurView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurView)
        
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        sideBarTableViewController.tableView.scrollsToTop  = false
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        sideBarTableViewController.firAuthUser = firAuthUser
        sideBarTableViewController.tableView.reloadData()
        
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
    }
    
    
    func handleSwipe(){
        if !isSideBarOpen {
            showSideBar(true)
            delegate?.sideBarWillClose?()
        }
    }
    
    func handleTap(){
        if isSideBarOpen {
            showSideBar(false)
            delegate?.sideBarWillClose?()
        }
    }
    
    func showSideBar(shouldOpen:Bool){
        animator.removeAllBehaviors()
        isSideBarOpen = shouldOpen
        
        let gravityX:CGFloat = (shouldOpen) ? 0.5 : -0.5
        let magnitude:CGFloat = (shouldOpen) ? 20 : -20
        let boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth - 1
        
        
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior(items: [sideBarContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityX, 0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior:UICollisionBehavior = UICollisionBehavior(items: [sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("sideBarBoundary", fromPoint: CGPointMake(boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior:UIPushBehavior = UIPushBehavior(items: [sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitude
        animator.addBehavior(pushBehavior)
        
        
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items: [sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            let location = touch.locationInView(sideBarContainerView)
            if CGRectContainsPoint(sideBarContainerView.bounds, location) == true {
                return false
            }
        }
        return true
    }
    
    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        delegate?.sideBarDidSelectButtonAtIndex(indexPath.row, section: indexPath.section)
    }
}
