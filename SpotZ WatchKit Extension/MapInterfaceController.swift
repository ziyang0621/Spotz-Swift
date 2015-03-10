//
//  MapInterfaceController.swift
//  SpotZ
//
//  Created by Ziyang Tan on 3/9/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import WatchKit
import Foundation


class MapInterfaceController: WKInterfaceController {
    
    @IBOutlet var map: WKInterfaceMap!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let ctx = context as? [String: Double] {
            var location = CLLocationCoordinate2DMake(ctx["placeLat"]!, ctx["placeLng"]!)
            var userLoc = CLLocationCoordinate2DMake(ctx["userLat"]!, ctx["userLng"]!)
   
            if location.latitude == userLoc.latitude && location.longitude == userLoc.longitude {
                let span = MKCoordinateSpan(
                    latitudeDelta: 0.005,
                    longitudeDelta: 0.005
                )
                let region = MKCoordinateRegion(center: location, span: span)
                map.setRegion(region)
                map.addAnnotation(location, withPinColor: WKInterfaceMapPinColor.Green)
            } else {
                map.addAnnotation(userLoc, withPinColor: WKInterfaceMapPinColor.Purple)
                map.addAnnotation(location, withPinColor: WKInterfaceMapPinColor.Green)
                let newDistance = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude).distanceFromLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
                let region = MKCoordinateRegionMakeWithDistance(userLoc, 2.5 * newDistance, 2.5 * newDistance)
                map.setRegion(region)
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
