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
    var name: String?
    var directions: [[String: Any]]?
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    let refreshControl = UIRefreshControl()
    var trydirections = Directions()
    
    var updateInfoLabelTimer: Timer?

    @IBOutlet weak var ContentView: UIView!
    
    @IBOutlet weak var LabelView: UIView!
    
    @IBOutlet weak var timeToDest: UILabel!
    @IBOutlet weak var showDestName: UILabel!
    
    //var destNode = LocationAnnotationNode()
    
    /*class func loadFromStoryboard() -> POIViewController {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ARView2") as! POIViewController
        // swiftlint:disable:previous force_cast
    }*/
    
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
        //call first so you fill values before entering timer loop
        updateInfoLabel()
        
        updateInfoLabelTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.updateInfoLabel()
        }
        
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
        ContentView.addSubview(sceneLocationView)
        sceneLocationView.frame = ContentView.bounds
        
        showDestName.text = "You are navigating to:"
        if let name = self.name {
            showDestName.text!.append(" \(name)\n")
        }
        print(showDestName.text!)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        sceneLocationView.frame = ContentView.bounds
    }

    func monitor_distance(location: CLLocation) {

        let destLocation = CLLocation(coordinate: destCoordinate, altitude: location.altitude)
        let distance = location.distance(from: destLocation)
        
        if distance < 10 {
            arrivalAlert(message: "You've reached your destination", entered: true)
            locationManager.stopUpdatingLocation()
        }
        
    }
    
    @objc
    func updateInfoLabel() {
        //timeToDest.text = " Hello this is a test \n"
        let store = DirectionStore()
                
        guard let destinationId = destid else {
            print("missing destination id")
            return
        }
        guard let vID = venueid else {
            print("missing venue id")
            return
        }
        if let currentLocation = sceneLocationView.sceneLocationManager.currentLocation  {
                
            store.getDirections(venueId: vID, destinationId: destinationId, latitude: Float(currentLocation.coordinate.latitude), longitude: Float(currentLocation.coordinate.longitude), refresh: { directs in
                self.trydirections = directs
                print(self.trydirections)
                DispatchQueue.main.async {
                    self.timeToDest.text = "Time to Destination: " + String(self.trydirections.time!.intValue) + " minutes"
                }
            }) {
               
            }
        }
        print("timer called")
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
    let okAction = UIAlertAction(title: "Return to navigation", style: .default)
    let action1 = UIAlertAction(title: "View nearby destinations", style: .default) { (action) in
        let switchViewController = self.navigationController?.viewControllers[1] as! DestinationVC
        self.navigationController?.popToViewController(switchViewController, animated: true)

        
        
    }
    alert.addAction(okAction)
    alert.addAction(action1)
    present(alert, animated: true, completion: nil)
  }
}

extension ARView2: CLLocationManagerDelegate {
    func locationManager(_ manager:CLLocationManager, didUpdateLocations: [CLLocation]) {
        monitor_distance(location: didUpdateLocations[0])
    }
}
