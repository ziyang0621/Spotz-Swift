//
//  ViewController.swift
//  SpotZ
//
//  Created by Ziyang Tan on 3/6/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import CoreLocation

var defaults = NSUserDefaults(suiteName: "group.com.ziyang.spotz")

var myLocations = [NSMutableDictionary]()

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults?.objectForKey("locations") != nil {
            myLocations = defaults?.objectForKey("locations") as [NSMutableDictionary]
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println(locations.last)
        let location = locations.last as CLLocation
        
        var placeName = ""
        
        var geocode = CLGeocoder()
        geocode.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if error == nil {
                if let placemark = placemarks?[0] as? CLPlacemark {
                    if let streetName = placemark.addressDictionary["Street"] as String? {
                        placeName += streetName
                    }
                    if let cityName = placemark.addressDictionary["City"] as String? {
                        placeName += ", " + cityName
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
            myLocations.append(dict)
            defaults?.setObject(myLocations, forKey: "locations")
            defaults?.synchronize()
            self.locationManager.stopUpdatingLocation()
            
            KVNProgress.showSuccess()
        })
        
        
    }

    @IBAction func rememberLocation(sender: AnyObject) {
        KVNProgress.show()
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func viewLocations(sender: AnyObject) {
        for location in myLocations {
            println(location)
        }
        
        let viewSpotsVC = UIStoryboard.viewSpotsViewController()
        self.navigationController?.pushViewController(viewSpotsVC!, animated: true)
    }

}

