//
//  SideBarViewController.swift
//  Souvenify
//
//  Created by Dhiraj Das on 8/31/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SideBarTableViewControllerDelegate{
    func sideBarControlDidSelectRow(indexPath:NSIndexPath)
}

class SideBarTableViewController: UITableViewController {
    
    var delegate:SideBarTableViewControllerDelegate?
    var tableData:Array<String> = []
    var firAuthUser : FIRAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != 0 {
            return tableData.count
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell")
        
        if cell == nil && indexPath.section == 1 {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkTextColor()
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
            
            cell!.selectedBackgroundView = selectedView
            cell!.textLabel?.text = tableData[indexPath.row]
            
            return cell!
        }
        else{
            cell = UITableViewCell(style: .Default, reuseIdentifier: "Cell")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkTextColor()
            
            let profileIconView =  UIImageView(frame: CGRectMake(0, 0, 50, 50))
            profileIconView.translatesAutoresizingMaskIntoConstraints = false
            let profileImage = UIImage(data: NSData(contentsOfURL: (firAuthUser?.currentUser?.photoURL)!)!)
            profileIconView.image = profileImage
            cell?.contentView.addSubview(profileIconView)
            cell?.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .CenterX, relatedBy: .Equal, toItem: profileIconView, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            cell?.contentView.addConstraint(NSLayoutConstraint(item: cell!.contentView, attribute: .CenterY, relatedBy: .Equal, toItem: profileIconView, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
            cell?.contentView.addConstraint(NSLayoutConstraint(item: profileIconView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute ,multiplier: 1.0, constant: 50))
            cell?.contentView.addConstraint(NSLayoutConstraint(item: profileIconView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute ,multiplier: 1.0, constant: 50))
            
            let profileNameLabel = UILabel()
            profileNameLabel.text = firAuthUser?.currentUser?.email
            profileNameLabel.font = UIFont(name: "HelveticaNeue", size: 11)
            profileNameLabel.translatesAutoresizingMaskIntoConstraints = false
            cell?.contentView.addSubview(profileNameLabel)
            cell?.contentView.addConstraint(NSLayoutConstraint(item: profileIconView, attribute: NSLayoutAttribute.Bottom, relatedBy: .Equal, toItem: profileNameLabel, attribute: .Top, multiplier: 1.0, constant: 5.0))
            cell?.contentView.addConstraint(NSLayoutConstraint(item: profileIconView, attribute: .CenterX, relatedBy: .Equal, toItem: profileNameLabel, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
            
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            selectedView.backgroundColor = UIColor.clearColor()
            cell!.selectedBackgroundView = selectedView
            
            return cell!
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section != 0 {
            return 45
        }else {
            return 90
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideBarControlDidSelectRow(indexPath)
    }
    
}
