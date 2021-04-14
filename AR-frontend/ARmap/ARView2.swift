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
    var new_directions: [[String: Any]]?
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    let refreshControl = UIRefreshControl()
    var waypoint1 = CLLocationCoordinate2D()
        

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
        print(self.directions)
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        //altitude = 60
        //self.destCoordinate.latitude = CLLocationDegrees(42.427057615617244)
        //self.destCoordinate.longitude = CLLocationDegrees(-71.41381231790173)
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
//                "lat": 42.427309,
//                "lon": -71.413880
//            ]
       //self.directions![0] = point1
//        let point2: [String: Any] = [
//                "lat": 42.427162344731606,
//                "lon": -71.41387137133471
//            ]
//
//        let point3: [String: Any] = [
//                "lat": 42.42711779845314,
//                "lon": -71.41374933081991
//            ]
//
          //self.directions?.append(point1)
//        self.directions?.append(point2)
//        self.directions?.append(point3)
        
        getDirectionWaypoints()
            
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
        
        let waypointLoc = CLLocation(coordinate: self.waypoint1, altitude: location.altitude)
        let waypointdistance = location.distance(from: waypointLoc)
        
        print(waypoint1)
        
        if waypointdistance < 10 {
            print("waypoint reached")
            //arrivalAlert(message: "Head to next waypoint", entered: true)
            
            //sceneLocationView.removeAllNodes()
            //let new_directions
            //let notfirst = DropFirstSequence(self.directions!, dropping: 1)
            //for point in notfirst{
                //new_directions!.append(point)
           // }
            
            //self.directions = new_directions
//            let point_1 = self.directions![1]
//            let lat_val = point_1["lat"] ?? 0
//            let lon_val = point_1["lon"] ?? 0
//            let latitude: CLLocationDegrees = lat_val as! CLLocationDegrees
//            let longitude: CLLocationDegrees = lon_val as! CLLocationDegrees
//
//            var pointCoord = CLLocationCoordinate2D()
//            pointCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
//
//            self.waypoint1 = pointCoord
            updateWaypoints()
              //getDirectionWaypoints()
            
        }

        let destLocation = CLLocation(coordinate: destCoordinate, altitude: location.altitude)
        let distance = location.distance(from: destLocation)
        
        if distance < 10 {
            arrivalAlert(message: "You've reached your destination", entered: true)
            locationManager.stopUpdatingLocation()
        }
        
        
        
    }
    

    func updateWaypoints(){
        
        // destroy existing waypoints - sceneLocation.removeAllNodes()
        print("removenodes")
        sceneLocationView.removeAllNodes()
        
        //pull waypoints
        print("pull new points")
        apiDirections()
        
        print("display new points")
        //display new waypoints
        getDirectionWaypoints()
        
        //update distance/time overlay
    //
    }
    
    func getDirectionWaypoints() {
        print("getting waypoints")
        
        
        let point_1 = self.directions![0]
        let lat_val = point_1["lat"] ?? 0
        let lon_val = point_1["lon"] ?? 0
        
        
    
        let latitude: CLLocationDegrees = lat_val as! CLLocationDegrees
        let longitude: CLLocationDegrees = lon_val as! CLLocationDegrees
    
        var pointCoord = CLLocationCoordinate2D()
        pointCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
        
        self.waypoint1 = pointCoord
    
        let location2 = CLLocation(coordinate: pointCoord, altitude: Double(altitude!))

        let image2 = UIImage(named: "pin2")!

        let waypoint = LocationAnnotationNode(location: location2, image: image2)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: waypoint)
    
        let notfirst = DropFirstSequence(self.directions!, dropping: 1)
        for point in notfirst{
        
        //var pointCoordinate = CLLocationCoordinate2D()
            //print(point)
            let lat_val = point["lat"] ?? 0
            let lon_val = point["lon"] ?? 0
        
            let latitude: CLLocationDegrees = lat_val as! CLLocationDegrees
            let longitude: CLLocationDegrees = lon_val as! CLLocationDegrees
        
            var pointCoord = CLLocationCoordinate2D()
            pointCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
        
            let location2 = CLLocation(coordinate: pointCoord, altitude: Double(altitude!))
    
            let image2 = UIImage(named: "pinfuturewaypoint")!

            let waypoint = LocationAnnotationNode(location: location2, image: image2)
            sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: waypoint)
        }
    }
    
    func apiDirections(){
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.armaps.net"
        components.path = "/api/venues/" +  String(self.venueid ?? 0) + "/destinations/" + String(self.destid ?? 0) + "/directions/"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(self.destCoordinate.latitude)),
            URLQueryItem(name: "lon", value: String(self.destCoordinate.longitude))
        ]
        guard let apiUrl = components.url else { return  }
        print(apiUrl)
        var request = URLRequest(url: apiUrl)

        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {
            (data, response, err) in
            guard let data = data, err == nil else {
                print("getDestinations: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getDestinations: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            //let jsonObj = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getDestinations: failed JSON deserialization")
                return
            }
            print(data)
            var directions = Directions()
            //let venuesReceived = jsonObj["data"] as ? [String: Any]
            let directionjson = jsonObj
            print(directionjson)
            //TODO: depend on what venues' names are in the tables
            if (directionjson.count == Directions.nFields + 1) {
                directions = Directions(data:(directionjson["data"] as! [[String:Any]]),
                                        distance: (directionjson["distance"] as! NSNumber),
                                        time: (directionjson["time_estimate"] as! NSNumber))
            } else {
                print("getDest: Received unexpected number of fields: \(String(describing: directionjson.count)).")
            }
            DispatchQueue.main.async {
                self.directions = directions.data

                
            }

        }.resume()
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
