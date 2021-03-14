//
//  File.swift
//  ARmap
//
//  Created by Claire Blazewicz on 3/13/21.
//

import Foundation
import ARCL
import CoreLocation

class ARView2: UIViewController, CLLocationManagerDelegate {
    var sceneLocationView = SceneLocationView()
    var lat: Float?
    var lon: Float?
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    //var destNode = LocationAnnotationNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*AR setup */
        self.destCoordinate.latitude = CLLocationDegrees(lat!)
        self.destCoordinate.longitude = CLLocationDegrees(lon!)
        //let destCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat!), longitude: CLLocationDegrees(lon!))
        let location = CLLocation(coordinate: destCoordinate, altitude: 300)
        
        let image = UIImage(named: "pin")!

        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        /*if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }*/
        
        /*annotationNode = LocationAnnotationNode(location: nil, image: image)
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode) // Current location
        annotationNode.annotationNode.name = "My location"*/
        
        monitor_distance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneLocationView.frame = view.bounds
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Arrived at: \(region.identifier)")
        arrivalAlert(message: "Arrived at: \(region.identifier) region.", entered: true)
        locationManager.stopUpdatingLocation() //stops fetching GPS data
        
    }
    /*func addcurrentlocationnode() {
        guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.addcurrentlocationnode()
            }
            return
        }
        // Copy the current location because it's a reference type. Necessary?
        let referenceLocation = CLLocation(coordinate: currentLocation.coordinate,
                                           altitude: currentLocation.altitude)
        let startingPoint = CLLocation(coordinate: referenceLocation.coordinate, altitude: referenceLocation.altitude)
        //let originNode = LocationNode(location: startingPoint)
        print(currentLocation.coordinate)
        
        let circularRegion = CLCircularRegion.init(center: currentLocation.coordinate,
                                                   radius: 50.0,
                                                   identifier: "Home")
        
        circularRegion.notifyOnEntry = true
        circularRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: circularRegion)
        
    }*/
    /*func render(_ location: CLLocation) {
         /*declare coordinate w/ lat and long of input param*/
         let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
         
         let circularRegion = CLCircularRegion.init(center: coordinate,
                                                    radius: 50.0,
                                                    identifier: "Home")
         
         circularRegion.notifyOnEntry = true
         circularRegion.notifyOnExit = true
         
         locationManager.startMonitoring(for: circularRegion)
         /*
         /* sets the span on map w/ lat and long */
         let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
         let region = MKCoordinateRegion(center: coordinate, span: span)
         
         mapView.setRegion(region, animated: true)*/
         /*mark map to show where coord is*/
         let pin = MKPointAnnotation()
         pin.coordinate = coordinate
         mapView.addAnnotation(pin)
     }*/
    func monitor_distance() {
        guard let currentLocation = sceneLocationView.sceneLocationManager.currentLocation else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.monitor_distance()
            }
            return
        }
        
        let location = CLLocation(coordinate: destCoordinate, altitude: currentLocation.altitude)
        let distance = sceneLocationView.sceneLocationManager.currentLocation?.distance(from: location)
        
        if distance! < 20 {
            arrivalAlert(message: "You've reached your destination", entered: true)
        }
        
    }
    
}

// MARK: Helper Extensions
extension UIViewController {
  func arrivalAlert(message: String, entered: Bool) {
    let alert = UIAlertController(title: "Arrived", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
    print("arrived")
  }
}
