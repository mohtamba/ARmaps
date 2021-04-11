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
    var trydirections = Directions()
    let locationManager = CLLocationManager()
    var destCoordinate = CLLocationCoordinate2D()
    var refreshControl = UIRefreshControl()

    
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
        print(imageUrl)
        destinationImage .sd_setImage(with: URL(string: imageUrl), placeholderImage: placeHolderImage, options: [.continueInBackground], context: nil, progress: nil, completed: {(downloadedImage, downloadException, cacheType, downloadURL) in
                    if let downloadException = downloadException {
                        print("Error downloading image: \(downloadException.localizedDescription)")
                    } else {
                        print("successfully downloaded image: \(String(describing: downloadURL?.absoluteString))")
                    }
                })
        destinationName.text = dest?.name
        destinationName.sizeToFit()
        destinationDescription.text = dest?.description
        destinationDescription.sizeToFit()
        
        // Do any additional setup after loading the view.

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        locationManager.startUpdatingLocation()
        
        refresh()

    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refresh()
    }
        
    private func refresh() {
        
        let store = DirectionStore()
        
        guard let destinationId = dest?.id else {
            print("missing destination id")
            return
        }
        guard let vID = venueId else {
            print("missing venue id")
            return
        }
        // gets authorization status from manager
        let status = locationManager.authorizationStatus
        var currentLocation: CLLocation!

        if status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse {
            currentLocation = locationManager.location
                        
            
            store.getDirections(venueId: vID, destinationId: destinationId, latitude: Float(currentLocation.coordinate.latitude), longitude: Float(currentLocation.coordinate.longitude), refresh: { directs in
                self.trydirections = directs
                print(self.trydirections)
                DispatchQueue.main.async {
                    self.destinationTime.text = "Time to Destination: " + String(self.trydirections.time!.intValue) + " minutes"
                    self.destinationDistance.text = "Distance to Destination: " + String(self.trydirections.distance!.intValue) + " miles"
                    self.destinationTime.sizeToFit()
                    self.destinationDistance.sizeToFit()
                    self.directions = self.trydirections.data
                }
            }) {
                DispatchQueue.main.async {
                    // stop the refreshing animation upon completion:
                    self.refreshControl.endRefreshing()
                }
            }
        }
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
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.destCoordinate.latitude = CLLocationDegrees(locValue.latitude)
        self.destCoordinate.longitude = CLLocationDegrees(locValue.longitude)
        
    }
    
    
}
