//
//  DirectionsStore.swift
//  ARmap
//
//  Created by Kate Carlton on 4/1/21.
//

import Foundation

struct DirectionStore {
    private let serverUrl = "https://api.armaps.net/"
    
    func getDirections(venueId: Int, destinationId: Int, latitude: Float, longitude: Float, refresh: @escaping (Directions) -> (), completion: @escaping () -> ()) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.armaps.net"
        components.path = "/api/venues/" +  String(venueId) + "/destinations/" + String(destinationId) + "/directions/"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude))
        ]
        guard let apiUrl = components.url else {
            print("getDirections: Bad URL")
            return
        }
        print(apiUrl)
            
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer { completion() }
            guard let data = data, error == nil else {
                print("getDirections: NETWORKING ERROR")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("getDirections: HTTP STATUS: \(httpStatus.statusCode)")
                return
            }
            //let jsonObj = try? JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                print("getDirections: failed JSON deserialization")
                return
            }
            var directions = Directions()
            let directionjson = jsonObj

            if (directionjson.count == Directions.nFields + 1) {
                
                directions = Directions(data:(directionjson["data"] as! [[String:Any]]),
                                        distance: (directionjson["distance"] as! NSNumber),
                                        time: (directionjson["time_estimate"] as! NSNumber))
            } else {
                print("getDirections: Received unexpected number of fields: \(directionjson.count) instead of \(Directions.nFields).")
            }
            refresh(directions)
        }
        task.resume()
    }
}
