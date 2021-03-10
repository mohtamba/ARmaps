/*
    TODO
    1) I guess we don't really need the postVenues function right now?
            cuz we are not storing any data so far. 
 */
import Foundation
struct VenueStore {
    private let serverUrl = "https://YOUR_SERVER/"
    func getVenues(refresh: @escaping ([Venue]) -> (),
                       completion: @escaping () -> ()) {
            guard let apiUrl = URL(string: serverUrl+"api/venues/?lat=42.29&lon=-83.72") else {
                print("getVenues: Bad URL")
                return
            }
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { completion() }
                guard let data = data, error == nil else {
                    print("getChatts: NETWORKING ERROR")
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
                var venues = [Venue]()
                //let venuesReceived = jsonObj["data"] as ? [String: Any]
                let venuesReceived = jsonObj["data"] as? [[String:Any]] ?? []  //TODO: depend on what venues' names are in the tables
                for venueEntry in venuesReceived {
                    if (venueEntry.count == Venue.nFields) {
                        print("to check what's in the venueentry")
                        //TODO: pull destinations into the array
                        //print(venueEntry[0])
                        //venues += Venue(json:venueEntry)!
//                            [Venue(venue_name: venueEntry[0],
//                                             description: venueEntry[1],
//                                             imageUrl: venueEntry[2],
//                                             lat: venueEntry[3],
//                                             lon:venueEntry[4]
//                                             )]
                    } else {
                        print("getChatts: Received unexpected number of fields: \(venueEntry.count) instead of \(Venue.nFields).")
                    }
                }
                refresh(venues)
            }
            task.resume()
        }
    func get_destination_by_Venues(refresh: @escaping ([Venue]) -> (),
                       completion: @escaping () -> ()) {
            guard let apiUrl = URL(string: serverUrl+"api/venues/152/destinations?lat=42.29&lon=-83.72") else {
                print("getVenues: Bad URL")
                return
            }
            
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                defer { completion() }
                guard let data = data, error == nil else {
                    print("getChatts: NETWORKING ERROR")
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
                var venues = [Venue]()
                //let venuesReceived = jsonObj["data"] as ? [String: Any]
                let venuesReceived = jsonObj["data"] as? [[String:Any]] ?? []  //TODO: depend on what venues' names are in the tables
                for venueEntry in venuesReceived {
                    if (venueEntry.count == Venue.nFields) {
                        print("to check what's in the venueentry")
                            //TODO: pull destinations into the array
                    } else {
                        print("getChatts: Received unexpected number of fields: \(venueEntry.count) instead of \(Venue.nFields).")
                    }
                }
                refresh(venues)
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
