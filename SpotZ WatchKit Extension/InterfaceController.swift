//
//  InterfaceController.swift
//  SpotZ WatchKit Extension
//
//  Created by Ziyang Tan on 3/6/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    
    @IBOutlet var spotsTable: WKInterfaceTable!
    
    var defaults = NSUserDefaults(suiteName: "group.com.ziyang.spotz")
    
    var myLocations = [NSMutableDictionary]()
    
    let locationManager = CLLocationManager()
    
    var selectedTableCell = false
    
    var selectedTableCellRow = 0
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func addSpot() {
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.locationManager.stopUpdatingLocation()
        println(locations.last)
        let location = locations.last as CLLocation
        
        if selectedTableCell {
            
            let dict = myLocations[selectedTableCellRow] as NSMutableDictionary
            let placeLat = dict.objectForKey("lat") as Double
            let placeLng = dict.objectForKey("lng") as Double
            let userLat = location.coordinate.latitude
            let userLng = location.coordinate.longitude
            
            selectedTableCell = false

            pushControllerWithName("MapInterfaceController",
                context: ["placeLat":placeLat, "placeLng": placeLng, "userLat": userLat, "userLng": userLng])
            
        } else {
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
                
                self.loadTableData()
            })

        }
    }
    
    func loadTableData() {
        spotsTable.setNumberOfRows(myLocations.count, withRowType: "TableRowController")
        
        for (index, item) in enumerate(myLocations) {
            let row = spotsTable.rowControllerAtIndex(index) as TableRowController
            let dict = myLocations[index] as NSMutableDictionary
            let placeName = dict.objectForKey("placeName") as String
            row.placeNameLabel.setText(placeName)
            println(placeName)
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        selectedTableCellRow = rowIndex
        selectedTableCell = true
        locationManager.startUpdatingLocation()
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if defaults?.objectForKey("locations") != nil {
            myLocations = defaults?.objectForKey("locations") as [NSMutableDictionary]
        }
        
        loadTableData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
