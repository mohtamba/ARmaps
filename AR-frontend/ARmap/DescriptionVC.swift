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
import MapKit

class DescriptionVC: UIViewController, CLLocationManagerDelegate {
    
    var dest: Location?
    var venueId: Int?
    var directions: [[String: Any]]?
    var trydirections = Directions()
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    var userCoord = CLLocationCoordinate2D()
    
    @IBOutlet weak var destinationName: UILabel!
    @IBOutlet weak var destinationDescription: UITextView!
    @IBOutlet weak var destinationImage: UIImageView!
    @IBOutlet weak var destinationDistance: UILabel!
    @IBOutlet weak var destinationTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageEnd = String((dest?.imageUrl)!)
        let imageUrl = "https://api.armaps.net\(imageEnd)"
        let placeHolderImage = UIImage(named: "placeholder")!
        /*load image or show placeholder if no image exists - print message if download error*/
        destinationImage .sd_setImage(with: URL(string: imageUrl), placeholderImage: placeHolderImage, options: [.continueInBackground], context: nil, progress: nil, completed: {(downloadedImage, downloadException, cacheType, downloadURL) in
            if let downloadException = downloadException {
                print("Error downloading image: \(downloadException.localizedDescription)")
            } else {
                print("successfully downloaded image: \(String(describing: downloadURL?.absoluteString))")
            }
        })
        
        /*assign remaining label values - passed from last scene*/
        destinationName.text = dest?.name
        destinationName.sizeToFit()
        destinationDescription.text = dest?.description
        destinationDescription.sizeToFit()
                
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()

        // For use in foreground
        locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()

        }

    }

    private func getLabelData() {
        
        //getUserCoord()
        
        let store = DirectionStore()
        
        guard let destinationId = dest?.id else {
            print("missing destination id")
            return
        }
        guard let vID = venueId else {
            print("missing venue id")
            return
        }

        store.getDirections(venueId: vID, destinationId: destinationId, latitude: Float(userCoord.latitude), longitude: Float(userCoord.longitude), refresh: { directs in
            self.trydirections = directs
            print(self.trydirections)
            DispatchQueue.main.async {
                self.destinationTime.text = "Time to Destination: " + String(self.trydirections.time!.intValue) + " minutes"
                self.destinationDistance.text = "Distance to Destination: " + String(self.trydirections.distance!.intValue) + " miles"
                self.destinationTime.sizeToFit()
                self.destinationDistance.sizeToFit()
                self.directions = self.trydirections.data
            }
        }) {}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ARView2 {
            dest.lat = self.dest?.lat
            dest.lon = self.dest?.lon
            dest.altitude = self.dest?.altitude
            dest.destid = self.dest?.id
            dest.directions = self.directions
            dest.name = self.dest?.name
            dest.venueid = self.venueId
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* "locations is an array of locations as they change sent from CL */
        /* we just grab first location we get and stop updating */
        if let location = locations.first {
            manager.stopUpdatingLocation()
            render(location)
        }
        
    }
    
    func render(_ location: CLLocation) {
        userCoord.latitude = location.coordinate.latitude
        userCoord.longitude = location.coordinate.longitude
        /*now that we have user loc we can make API call to get label info*/
        getLabelData()

    }
    
}
