//
//  ViewSpotsViewController.swift
//  SpotZ
//
//  Created by Ziyang Tan on 3/7/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

let kSpotTableCellID = "SpotTableViewCell"

class ViewSpotsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var spotsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spotsTableView.delegate = self
        spotsTableView.dataSource = self
        spotsTableView.registerNib(UINib(nibName: kSpotTableCellID, bundle: nil), forCellReuseIdentifier: kSpotTableCellID)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if defaults?.objectForKey("locations") != nil {
            myLocations = defaults?.objectForKey("locations") as [NSMutableDictionary]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kSpotTableCellID) as SpotTableViewCell
        
        let dict = myLocations[indexPath.row] as NSMutableDictionary
        let placeName = dict.objectForKey("placeName") as String
        let time = dict.objectForKey("time") as NSDate
        
        let interval = NSDate().daysAfterDate(time)
        
        var dateString = ""
        if interval == 0 {
            dateString = "Today"
        } else if interval == 1 {
            dateString = "Yesterday"
        } else {
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "mm/dd/yyyy"
            dateString = dateFormat.stringFromDate(time)
        }
        
        cell.placeNameLabel.text = placeName
        cell.dateLabel.text = dateString
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
