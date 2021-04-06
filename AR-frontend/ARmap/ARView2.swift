//
//  File.swift
//  ARmap
//
//  Created by Claire Blazewicz on 3/13/21.
//

import Foundation
import ARCL
import CoreLocation

class ARView2: UIViewController {
    var sceneLocationView = SceneLocationView()
    var lat: Float?
    var lon: Float?
    var altitude: Float?
    var venueid: Int?
    var destid: Int?
    var directions: [[String: Any]]?
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    let refreshControl = UIRefreshControl()
        
    //var destNode = LocationAnnotationNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.addTarget(self, action: #selector(DestinationVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        /*AR setup */
        self.destCoordinate.latitude = CLLocationDegrees(lat!)
        self.destCoordinate.longitude = CLLocationDegrees(lon!)
        //let destCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat!), longitude: CLLocationDegrees(lon!))
        let location = CLLocation(coordinate: destCoordinate, altitude: Double(altitude!))
        
        let image = UIImage(named: "pin")!

        let annotationNode = LocationAnnotationNode(location: location, image: image)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        //*claire testing*//
        
//        let point1: [String: Any] = [
//                "lat": 42.427017321626025,
//                "lon": -71.41558798522215
//            ]
//
//        let point2: [String: Any] = [
//                "lat": 42.42808642528542,
//                "lon": -71.41284140334182
//            ]
        
        
//        self.directions?.append(point1)
//        self.directions?.append(point2)
        
        for point in self.directions ?? []{
            
            //var pointCoordinate = CLLocationCoordinate2D()
            print(point)
            let lat_val = point["lat"] ?? 0
            let lon_val = point["lon"] ?? 0
            
            let latitude: CLLocationDegrees = lat_val as! CLLocationDegrees
            let longitude: CLLocationDegrees = lon_val as! CLLocationDegrees
            
            var pointCoord = CLLocationCoordinate2D()
            pointCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
            
            let location2 = CLLocation(coordinate: pointCoord, altitude: Double(altitude!))
        
            let image2 = UIImage(named: "pin2")!

            let waypoint = LocationAnnotationNode(location: location2, image: image2)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: waypoint)
        }
        
        
        //getDirectionWaypoints()
            
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneLocationView.frame = view.bounds
    }

    func monitor_distance(location: CLLocation) {

        let destLocation = CLLocation(coordinate: destCoordinate, altitude: location.altitude)
        let distance = location.distance(from: destLocation)
        
        if distance < 10 {
            arrivalAlert(message: "You've reached your destination", entered: true)
            locationManager.stopUpdatingLocation()
        }
        
    }
    
//    func getDirectionWaypoints() {
//
//        for point in directions ?? []{
//
//            //var pointCoordinate = CLLocationCoordinate2D()
//            print(point)
//            let lat_val = point["lat"] ?? 0
//            let lon_val = point["lon"] ?? 0
//
//            let latitude: CLLocationDegrees = lat_val as! CLLocationDegrees
//            let longitude: CLLocationDegrees = lon_val as! CLLocationDegrees
//
//            var pointCoord = CLLocationCoordinate2D()
//            pointCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
//
//            let location = CLLocation(coordinate: pointCoord, altitude: Double(altitude!))
//
//            let image = UIImage(named: "pin2")!
//
//            let annotationNode = LocationAnnotationNode(location: location, image: image)
//            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
//        }
//    }
}

// MARK: Helper Extensions
extension UIViewController {
  func arrivalAlert(message: String, entered: Bool) {
    let alert = UIAlertController(title: "Arrived", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension ARView2: CLLocationManagerDelegate {
    func locationManager(_ manager:CLLocationManager, didUpdateLocations: [CLLocation]) {
        monitor_distance(location: didUpdateLocations[0])
    }
}
