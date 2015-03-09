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
    
    var location: CLLocationCoordinate2D?

    @IBOutlet var map: WKInterfaceMap!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let ctx = context as? [String: Double] {
            location = CLLocationCoordinate2DMake(ctx["lat"]!, ctx["lng"]!)
            
            let span = MKCoordinateSpan(
                latitudeDelta: 0.005,
                longitudeDelta: 0.005
            )
            
            let region = MKCoordinateRegion(center: location!, span: span)
            
            map.setRegion(region)
            
            map.addAnnotation(location!, withPinColor: WKInterfaceMapPinColor.Red)
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
