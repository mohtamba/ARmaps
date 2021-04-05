//
//  DescriptionVC.swift
//  ARmap
//
//  Created by Mohammad Tambawala on 3/13/21.
//

import UIKit
import SDWebImage
import CoreLocation
import Foundation

class DescriptionVC: UIViewController, CLLocationManagerDelegate{
    var dest: Location?
    var venueId: Int?
    var directions: [[String: Any]]?
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    
    
    
    @IBOutlet weak var destinationName: UILabel!
    
    @IBOutlet weak var destinationDescription: UITextView!
    
    
    @IBOutlet weak var destinationImage: UIImageView!
    
    @IBOutlet weak var destinationDistance: UILabel!
    
    @IBOutlet weak var destinationTime: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageEnd = String((dest?.imageUrl)!)
        let imageUrl = "https://api.armaps.net\(imageEnd)"
        print(imageUrl)
        destinationImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "photo"), options: [.progressiveLoad])
        destinationName.text = dest?.name
        destinationName.sizeToFit()
        destinationDescription.text = dest?.description
        destinationDescription.sizeToFit()
        

        
        // Do any additional setup after loading the view.

        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        /*AR setup */
        //let destCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat!), longitude: CLLocationDegrees(lon!))

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.armaps.net"
        components.path = "/api/venues/" +  String(venueId ?? 0) + "/destinations/" + String(dest?.id ?? 0) + "/directions/"
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
                self.destinationTime.text = "Time to Destination: " + String(directions.time!.intValue) + " minutes"
                self.destinationDistance.text = "Distance to Destination: " + String(directions.distance!.intValue) + " miles"
                self.destinationTime.sizeToFit()
                self.destinationDistance.sizeToFit()
                self.directions = directions.data

                
            }

        }.resume()
        
    

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ARView2 {
            dest.lat = self.dest?.lat
            dest.lon = self.dest?.lon
            dest.altitude = self.dest?.altitude
            dest.destid = self.dest?.id
            dest.directions = self.directions
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.destCoordinate.latitude = CLLocationDegrees(locValue.latitude)
        self.destCoordinate.longitude = CLLocationDegrees(locValue.longitude)
        
    }
    
    
}
