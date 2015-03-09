//
//  ViewSpotsViewController.swift
//  SpotZ
//
//  Created by Ziyang Tan on 3/7/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import CoreLocation

let kSpotTableCellID = "SpotTableViewCell"

class ViewSpotsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var defaults = NSUserDefaults(suiteName: "group.com.ziyang.spotz")
    
    var myLocations = [NSMutableDictionary]()
    
    let locationManager = CLLocationManager()
    
    let dateFormat = NSDateFormatter()

    @IBOutlet var spotsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        spotsTableView.delegate = self
        spotsTableView.dataSource = self
        spotsTableView.registerNib(UINib(nibName: kSpotTableCellID, bundle: nil), forCellReuseIdentifier: kSpotTableCellID)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Spot", style: UIBarButtonItemStyle.Bordered, target: self, action: "addLocation")
        self.navigationItem.title = "Spotz"
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.locationManager.stopUpdatingLocation()
        println(locations.last)
        let location = locations.last as CLLocation
        
        var placeName = ""
        
        let geocode = CLGeocoder()
        geocode.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                if let placemark = placemarks?[0] as? CLPlacemark {
                    if let streetName = placemark.addressDictionary["Street"] as String? {
                        placeName += streetName
                    }
                    if let cityName = placemark.addressDictionary["City"] as String? {
                        if placeName == "" {
                            placeName += cityName
                        } else {
                            placeName += ", " + cityName
                        }
                    }
                }
            } else {
                println(error)
            }
            
            let dict = NSMutableDictionary()
            dict["lat"] = location.coordinate.latitude
            dict["lng"] = location.coordinate.longitude
            dict["time"] = NSDate()
            dict["placeName"] = placeName
            self.myLocations.insert(dict, atIndex: 0)
            self.defaults?.setObject(self.myLocations, forKey: "locations")
            self.defaults?.synchronize()
            
            self.spotsTableView.reloadData()
            KVNProgress.showSuccess()
        })
        

    }
    
    func addLocation() {
        KVNProgress.show()
        locationManager.startUpdatingLocation()
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
        dateFormat.dateFormat = "hh:mm a"
        if time.isToday() {
            dateString = "Today   " + dateFormat.stringFromDate(time)
        } else if time.isYesterday() {
            dateString = "Yesterday   " + dateFormat.stringFromDate(time)
        } else {
            dateFormat.dateFormat = "MM/dd/yyyy'   'hh:mm a"
            dateString = dateFormat.stringFromDate(time)
        }
    
        cell.placeNameLabel.text = placeName
        cell.dateLabel.text = dateString

        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            myLocations.removeAtIndex(indexPath.row)
            defaults?.setObject(myLocations, forKey: "locations")
            defaults?.synchronize()
            spotsTableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict = myLocations[indexPath.row] as NSMutableDictionary
        let lat = dict.objectForKey("lat") as Double
        let lng = dict.objectForKey("lng") as Double
        let coordinate = CLLocationCoordinate2DMake(lat, lng)
        
        var mapVC = UIStoryboard.mapViewController()
        mapVC?.coordinate = coordinate
        self.navigationController?.pushViewController(mapVC!, animated: true)
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
