//
//  MapViewController.swift
//  SpotZ
//
//  Created by Ziyang Tan on 3/8/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    var routeDetails = MKRoute()
    var coordinate: CLLocationCoordinate2D?
    var thePlaceMark: CLPlacemark?
    var firstLoadFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let location = CLLocation(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
        
        KVNProgress.show()
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarkers, error) -> Void in
            if error == nil {
                if let pls = placemarkers?[0] as? CLPlacemark {
                    self.thePlaceMark = pls
                    self.addAnnotation(pls)
                    self.routeDirection(pls)
                }
            } else {
                println(error)
            }

        })
    }
    
    func routeDirection(placemark: CLPlacemark) {
        var directionRequest = MKDirectionsRequest()
        directionRequest.setSource(MKMapItem.mapItemForCurrentLocation())
        var placemark = MKPlacemark(placemark: placemark)
        directionRequest.setDestination(MKMapItem(placemark: placemark))
        directionRequest.transportType = MKDirectionsTransportType.Walking
        var direstions = MKDirections(request: directionRequest)
        direstions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error == nil {
                if let resp = response as MKDirectionsResponse! {
                    println("in response")
                    self.routeDetails = resp.routes.last as MKRoute
                    self.mapView.addOverlay(self.routeDetails.polyline)
                    self.firstLoadFinished = true
                }
                
            } else {
                println(error)
            }
        }
    }
    
    func addAnnotation(placemark: CLPlacemark) {
        var point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude)
        println(placemark)
        if let title = placemark.addressDictionary["Street"] as String? {
            point.title = title
        }
        if let subtitle = placemark.addressDictionary["City"] as String? {
            point.subtitle = subtitle
        }
        mapView.addAnnotation(point)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let routeLineRenderer = MKPolylineRenderer(polyline: routeDetails.polyline)
        routeLineRenderer.strokeColor = UIColor.redColor()
        routeLineRenderer.lineWidth = 5
        return routeLineRenderer
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else if annotation.isKindOfClass(MKPointAnnotation) {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomPinAnnotationView") as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomPinAnnotationView")
            } else {
                pinView!.annotation = annotation
            }
            return pinView!
        }
        return nil
    }
    
    func showRegon(placemark: CLPlacemark) {
        var userLoc = self.mapView.userLocation
        
        let newDistance = CLLocation(latitude: userLoc.coordinate.latitude, longitude: userLoc.coordinate.longitude).distanceFromLocation(CLLocation(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude))
        let region = MKCoordinateRegionMakeWithDistance(userLoc.coordinate, 2 * newDistance, 2 * newDistance)
        let adjustRegion = self.mapView.regionThatFits(region)
        self.mapView.setRegion(adjustRegion, animated:true)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        if firstLoadFinished {
            showRegon(thePlaceMark!)
            KVNProgress.dismiss()
        }
    }

    @IBAction func openButtonPressed(sender: AnyObject) {
        let openMapsActionSheet = UIAlertController(title: "Open in Maps", message: "Choose a maps application", preferredStyle: .ActionSheet)
        openMapsActionSheet.addAction(UIAlertAction(title: "Apple Maps", style: .Default, handler: { (action: UIAlertAction!) -> Void in
            var placemark = MKPlacemark(placemark: self.thePlaceMark)
            var item = MKMapItem(placemark: placemark)
            let options = [MKLaunchOptionsDirectionsModeKey:
                MKLaunchOptionsDirectionsModeWalking,
                MKLaunchOptionsShowsTrafficKey: true]
            item.openInMapsWithLaunchOptions(options)
        }))
        openMapsActionSheet.addAction(UIAlertAction(title: "Google Maps", style: .Default, handler: { (action: UIAlertAction!) -> Void in
            if (UIApplication.sharedApplication().canOpenURL(NSURL(string:"comgooglemaps://")!)) {
                UIApplication.sharedApplication().openURL(NSURL(string:
                    "comgooglemaps://?saddr=\(self.mapView.userLocation.coordinate.latitude),\(self.mapView.userLocation.coordinate.longitude)&daddr=\(self.thePlaceMark!.location.coordinate.latitude),\(self.thePlaceMark!.location.coordinate.longitude)&directionsmode=walking")!)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string:
                    "http://maps.google.com/maps?saddr=\(self.mapView.userLocation.coordinate.latitude),\(self.mapView.userLocation.coordinate.longitude)&daddr=\(self.thePlaceMark!.location.coordinate.latitude),\(self.thePlaceMark!.location.coordinate.longitude)&directionsmode=walking")!)
            }
        }))
        openMapsActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(openMapsActionSheet, animated: true, completion: nil)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
