//
//  SearchResultViewController.swift
//  Souvenify
//
//  Created by Dhiraj Das on 8/30/16.
//  Copyright © 2016 Dhiraj Das. All rights reserved.
//

import UIKit

class SearchResultViewController: UITableViewController {

    var searchResults : [String]!
    var delegate : SearchResultViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResults = Array()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "searchResultCell")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.searchResults[indexPath.row]
        cell.backgroundView?.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.darkTextColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.dismissViewControllerAnimated(true, completion: {
        
            print(self.searchResults[indexPath.row])
            let correctedAddress:String! = self.searchResults[indexPath.row].stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
            print(correctedAddress)
            let url = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false")
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in

                do {
                    if data != nil{
                        let dic = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as!  NSDictionary
                        
                        let lat = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat")?.objectAtIndex(0) as! Double
                        let lon = dic["results"]?.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng")?.objectAtIndex(0) as! Double
                        
                        self.delegate?.locateWithLongitude(lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row] )
                    }
                }catch {
                    print("Error")
                }
            }
            
            task.resume()

        })
    }
    
    func reloadDataWithArray(array:[String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
}

protocol SearchResultViewControllerDelegate {
    
    func locateWithLongitude(longitude: Double, andLatitude lat:Double, andTitle title: String)
    
}
