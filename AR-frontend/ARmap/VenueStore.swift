/*
    TODO
    1) I guess we don't really need the postVenues function right now?
            cuz we are not storing any data so far. 
 */
import Foundation
struct LocationStore {
    private let serverUrl = "https://api.armaps.net/"
    func getVenues(refresh: @escaping ([Location]) -> (),
                       completion: @escaping () -> ()) {
            guard let apiUrl = URL(string: serverUrl+"api/venues/") else {
                print("getVenues: Bad URL")
                return
            }
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { completion() }
                guard let data = data, error == nil else {
                    print("getVenues: NETWORKING ERROR")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("getVenues: HTTP STATUS: \(httpStatus.statusCode)")
                    return
                }
                //let jsonObj = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data) as? [String:Any] else {
                    print("getVenues: failed JSON deserialization")
                    return
                }
                var venues = [Location]()
                //let venuesReceived = jsonObj["data"] as ? [String: Any]
                let venuesReceived = jsonObj["data"] as? [[String:Any]] ?? []  //TODO: depend on what venues' names are in the tables
                print(venuesReceived)
                for venueEntry in venuesReceived {
                    if (venueEntry.count == Location.nFields) {
                        print("to check what's in the venueentry")
                        //TODO: pull destinations into the array
                        print(venueEntry["description"] ?? "")
                        venues += [Location(name: (venueEntry["name"] as! String),
                                         description: (venueEntry["description"] as! String),
                                         imageUrl: (venueEntry["image_url"] as! String),
                                         lat: (venueEntry["latitude"] as! NSNumber).floatValue,
                                         lon:(venueEntry["longitude"] as! NSNumber).floatValue,
                                         id:(venueEntry["venue_id"] as! Int)
                                             )]
                    } else {
                        print("getVenues: Received unexpected number of fields: \(venueEntry.count) instead of \(Location.nFields).")
                    }
                }
                refresh(venues)
            }
            task.resume()
        }
    func get_destination_by_Venues(refresh: @escaping ([Location]) -> (),
                       completion: @escaping () -> ()) {
            guard let apiUrl = URL(string: serverUrl+"api/venues/1/destinations?lat=43.34208&lon=-86.27985") else {
                print("getDestinations: Bad URL")
                return
            }
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { completion() }
                guard let data = data, error == nil else {
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
                var destinations = [Location]()
                //let venuesReceived = jsonObj["data"] as ? [String: Any]
                let destinationsReceived = jsonObj["data"] as? [[String:Any]] ?? []  //TODO: depend on what venues' names are in the tables
                for venueEntry in destinationsReceived {
                    if (venueEntry.count == Location.nFields) {
                        print("to check what's in the destentry")
                            //TODO: pull destinations into the array
                    } else {
                        print("getDestinations: Received unexpected number of fields: \(venueEntry.count) instead of \(Location.nFields).")
                    }
                }
                refresh(destinations)
            }
            task.resume()
        }
//    func postChatt(_ chatt: Venue) {
//        let jsonObj = ["username": chatt.username,
//                               "message": chatt.message,
//                               "audio": chatt.audio]
//        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
//            print("postChatt: jsonData serialization error")
//            return
//        }
//
//        guard let apiUrl = URL(string: serverUrl+"postchatt/") else {
//            print("postChatt: Bad URL")
//            return
//        }
//
//        var request = URLRequest(url: apiUrl)
//        request.httpMethod = "POST"
//        request.httpBody = jsonData
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let _ = data, error == nil else {
//                print("postChatt: NETWORKING ERROR")
//                return
//            }
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
//                print("postChatt: HTTP STATUS: \(httpStatus.statusCode)")
//                return
//            }
//        }
//        task.resume()
//    }
}
