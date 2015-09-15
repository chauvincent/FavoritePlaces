//
//  ViewController.swift
//  FavoritePlaces
//
//  Created by Vincent Chau on 9/13/15.
//  Copyright © 2015 Vincent Chau. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol ViewControllerDelegate {
    func controller(controller: ViewController, didAddItem: [Favorite], andItem: [MKAnnotation])
}
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var instructionLabel: UILabel!
    @IBOutlet var map: MKMapView!
    var delegate: ViewControllerDelegate?
    var manager = CLLocationManager()
    var myFavorites: [Favorite] = []
    var myPath: [CLLocation] = []
    var userLocation = CLLocation()
    var savedAnnotations: [MKAnnotation] = []
    var isTracking:Bool? = nil
    var selectedRow:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        
    }
    override func viewDidAppear(animated: Bool) {
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        
        
        if(isTracking == true)
        {
            instructionLabel.hidden = false
            manager.startUpdatingLocation()
        }
        else if isTracking == false && selectedRow != nil
        {
            let selectedItem:Favorite = myFavorites[selectedRow!]
            let latitude:CLLocationDegrees = selectedItem.location.coordinate.latitude
            let longtitude:CLLocationDegrees = selectedItem.location.coordinate.longitude
            let latDel:CLLocationDegrees = 0.003
            let longDel:CLLocationDegrees = 0.003
            let span = MKCoordinateSpanMake(latDel, longDel)
            let location = CLLocationCoordinate2DMake(latitude, longtitude)
            let region = MKCoordinateRegionMake(location, span)
            
            instructionLabel.hidden = true
            self.map.setRegion(region, animated: true)
        }
        
        map.delegate = self
        map.showsUserLocation = true
        
        
        // Allow user tap gesture
        let doubleTap = UITapGestureRecognizer(target: self, action: "action:")
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)

        if savedAnnotations.count > 0{
         
            for point in savedAnnotations{
                map.addAnnotation(point)
            }
        }
    }
    
    // MARK: - UILongPressGestureRecognizer
    func action(gestureRecognizer: UITapGestureRecognizer){

        let touchPoint = gestureRecognizer.locationInView(self.map)
        let newCoord: CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoord
        
        let tappedLocaton = CLLocation.init(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        //manager.location!
        CLGeocoder().reverseGeocodeLocation(tappedLocaton) { (marker, error) -> Void in
            if(error != nil)
            {
                print("error")
            }
            
            if marker?.count > 0 {
                let pm = marker![0] as CLPlacemark

                var address:NSString = ""
                
                if(pm.subThoroughfare != nil && pm.thoroughfare != nil){
                        address = NSString(format: "%@ %@\n%@ %@\n%@\n%@", pm.subThoroughfare!, pm.thoroughfare!,
                        pm.postalCode!, pm.locality!,
                        pm.administrativeArea!,
                        pm.country!)
                }
                else if(pm.subThoroughfare == nil){
                        address = NSString(format: "%@\n%@ %@\n%@\n%@", pm.thoroughfare!,
                        pm.postalCode!, pm.locality!,
                        pm.administrativeArea!,
                        pm.country!)
                }
                else{
                        address = NSString(format: "%@ %@\n%@\n%@",
                        pm.postalCode!, pm.locality!,
                        pm.administrativeArea!,
                        pm.country!)
                }
                
                let newFavorite = Favorite(address: address, newLocation: self.manager.location!)
                
                self.myFavorites.append(newFavorite)
                annotation.title = "Favorite"
                annotation.subtitle = address as String
                self.savedAnnotations.append(annotation)
                self.map.addAnnotation(annotation)
                
            }
          
            self.delegate!.controller(self, didAddItem: self.myFavorites, andItem: self.savedAnnotations)
        }

    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Set Up Map On User Current Location
        userLocation = locations[0]
        myPath.append(userLocation as CLLocation)
        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
        let longtitude:CLLocationDegrees = userLocation.coordinate.longitude
        let latDel:CLLocationDegrees = 0.003
        let longDel:CLLocationDegrees = 0.003
        let span = MKCoordinateSpanMake(latDel, longDel)
        let location = CLLocationCoordinate2DMake(latitude, longtitude)
        let region = MKCoordinateRegionMake(location, span)
        
        if (myPath.count > 1){
            let sourceIndex = myPath.count - 1
            let destinationIndex = myPath.count - 2
            let sourceCoord = myPath[sourceIndex].coordinate
            let destCoord = myPath[destinationIndex].coordinate
            var a = [sourceCoord, destCoord]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            map.addOverlay(polyline)
        }
        map.setRegion(region, animated: true)
    }

    
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.redColor()
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    
    }
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

