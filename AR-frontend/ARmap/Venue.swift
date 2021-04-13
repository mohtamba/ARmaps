import Foundation
@propertyWrapper
struct LocPropWrapper {
    private var LocVar: String?
    var wrappedValue: String? {
        get { return LocVar }
        set {
            if let newValue = newValue {
                LocVar = (newValue == "null" || newValue.isEmpty) ? nil : newValue
            } else {
                LocVar = nil
            }
        }
    }
    init() {}
    init(wrappedValue: String?) {
        self.wrappedValue = wrappedValue
    }
}
struct Location {
    var name = ""
    //var distance: String?
    var description: String?
    @LocPropWrapper var imageUrl: String? = nil
    var lat: Float?
    var lon: Float?
    var altitude: Float?
    var distance: Double?
    var id: Int?
    //add geodata afterwards
    static let nFields = 7
    static let n1Fields = 8
}
/*Ideas from the apple instruction page
  To create an extension to the Venue model and add an initializer that takes
  as an argument a Dictionary that was provided by JSONSerialization framework*/
//extension Venue{
//    init?(json: [String: Any]) {
//        guard let name = json["name"] as? String,
//              //extract all properties and cast them to types that we expect
//              //if casting fails, the initilaization fails and we return nil
//            let description = json["decription"] as? String,
//            let imageurl = json["image_url"] as? String,
//            let lat = json["lat"] as? Float,
//            let lon = json["lon"] as? Float,
//            let id = json["venue_id"] as? Int
//            else {
//                return nil
//        }
//        self.venue_name = name
//        self.description = description
//        self.imageUrl = imageurl
//        self.lat = lat
//        self.lon = lon
//        self.id = id
//    }
//}
