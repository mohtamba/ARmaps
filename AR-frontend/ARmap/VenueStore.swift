/*
    TODO
    1) I guess we don't really need the postVenues function right now?
            cuz we are not storing any data so far. 
 */
import Foundation
struct LocationStore {
    
    
    private let serverUrl = "https://api.armaps.net/"
    mutating func getVenues(refresh: @escaping ([Location]) -> (),
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
                print("follows")
                //Get rid of settings of distance once the backend is down
                var counter = 1
                var distances_temp: [Double] = [0.1,0.3,1.4,1.6,2.4,2.6,3.4,4.4]
                for venueEntry in venuesReceived {
                    if (venueEntry.count == Location.nFields) {
                        counter += 1
                        venues += [Location(name: (venueEntry["name"] as! String),
                                         description: (venueEntry["description"] as! String),
                                         imageUrl: (venueEntry["image_url"] as! String),
                                         lat: (venueEntry["latitude"] as! NSNumber).floatValue,
                                         lon: (venueEntry["longitude"] as! NSNumber).floatValue,
                                         altitude: (venueEntry["altitude"] as! NSNumber).floatValue,
                                         distance: distances_temp[counter%8],
                                         id: (venueEntry["venue_id"] as! Int)
                                             )]
                    } else {
                        print("getVenues: Received unexpected number of fields: \(venueEntry.count) instead of \(Location.nFields).")
                    }
                }
                refresh(venues)
            }
            task.resume()
        }
    mutating func getVenuesdistance(lati: Double,
                                    longi: Double,
                                    refresh: @escaping ([Location]) -> (),
                                    completion: @escaping () -> ()) {
            guard let apiUrl = URL(string: serverUrl+"api/venues/?lat="+String(lati)+"&lon=" +
            String(longi)) else {
                print("getVenues: Bad URL")
                return
            }
            print("hihi: ", apiUrl)
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
                //print(venuesReceived)
                    //print("follows")
                //Get rid of settings of distance once the backend is down
                //var counter = 1
                //var distances_temp: [Double] = [0.1,0.3,1.4,1.6,2.4,2.6,3.4,4.4]
                for venueEntry in venuesReceived {
                    if (venueEntry.count == Location.n1Fields) {
                        //counter += 1
                        print("sth: ", (venueEntry["distance"] as! NSNumber).doubleValue)
                        venues += [Location(name: (venueEntry["name"] as! String),
                                         description: (venueEntry["description"] as! String),
                                         imageUrl: (venueEntry["image_url"] as! String),
                                         lat: (venueEntry["latitude"] as! NSNumber).floatValue,
                                         lon: (venueEntry["longitude"] as! NSNumber).floatValue,
                                         altitude: (venueEntry["altitude"] as! NSNumber).floatValue,
                                         distance: (venueEntry["distance"] as! NSNumber).doubleValue,
                                         id: (venueEntry["venue_id"] as! Int)
                                             )]
                    } else {
                        print("getVenues: Received unexpected number of fields: \(venueEntry.count) instead of \(Location.n1Fields).")
                    }
                }
                refresh(venues)
            }
            task.resume()
        }
    func get_destination_by_Venues_distance(venueId: Int,
                                            lati: Double,
                                            longi: Double,
                                   refresh: @escaping ([Location]) -> (),
                                   completion: @escaping () -> ()) {
        guard let apiUrl = URL(string: serverUrl+"api/venues/"+String(venueId)+"/destinations?lat="+String(lati)+"&lon=" +
        String(longi)) else {
                print("getDestinations: Bad URL")
                return
            }
            print("hihihihi ", apiUrl)
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
                for destEntry in destinationsReceived {
                    /*NOTE - added 1 b/c destinations API actually has venue_id stored too */
                    if (destEntry.count == Location.n1Fields+1) {
                        destinations += [Location(name: (destEntry["name"] as! String),
                                         description: (destEntry["description"] as! String),
                                         imageUrl: (destEntry["image_url"] as! String),
                                         lat: (destEntry["latitude"] as! NSNumber).floatValue,
                                         lon:(destEntry["longitude"] as! NSNumber).floatValue,
                                         altitude:(destEntry["altitude"] as! NSNumber).floatValue,
                                         distance: (destEntry["distance"] as! NSNumber).doubleValue,
                                         id:(destEntry["destination_id"] as! Int)
                                             )]
                    } else {
                        print("getDest: Received unexpected number of fields: \(destEntry.count).")
                    }
                }
                refresh(destinations)
            }
            task.resume()
        }
    func get_destination_by_Venues(venueId: Int,
                                   refresh: @escaping ([Location]) -> (),
                                   completion: @escaping () -> ()) {
            guard let apiUrl = URL(string: serverUrl+"api/venues/" +  String(venueId) + "/destinations/") else {
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
                for destEntry in destinationsReceived {
                    /*NOTE - added 1 b/c destinations API actually has venue_id stored too */
                    if (destEntry.count == Location.nFields + 1) {
                        destinations += [Location(name: (destEntry["name"] as! String),
                                         description: (destEntry["description"] as! String),
                                         imageUrl: (destEntry["image_url"] as! String),
                                         lat: (destEntry["latitude"] as! NSNumber).floatValue,
                                         lon:(destEntry["longitude"] as! NSNumber).floatValue,
                                         altitude:(destEntry["altitude"] as! NSNumber).floatValue,
                                         id:(destEntry["destination_id"] as! Int)
                                             )]
                    } else {
                        print("getDest: Received unexpected number of fields: \(destEntry.count).")
                    }
                }
                refresh(destinations)
            }
            task.resume()
        }
    
    
   
}
