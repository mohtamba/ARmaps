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
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
        
    //var destNode = LocationAnnotationNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
