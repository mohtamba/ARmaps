import UIKit
import Foundation
/*Welcome list todo:
    1) add a button so that users can refresh to generate a new list
    2) maybe also show the list of venues in the map
    3) maybe allow users to search nearby venues (add a search window)
    4) tobe continued
*/

class Welcome: UITableViewController{
    //to create a dictionary of arrays
    var venue_dictionary = [String: [Venue]]()
    var try1 = [Venue]()
    var A_to_Z = [String]()
    //add dumb venues--> to be deleted afterwards
    var miles_example = ["0.3 mile", "0.5 miles", "0.7 miles", "0.3 miles"]
    var spots_example = ["Harry Potter", "Potter's mum", "Mum's Potter", "Simpsons"]
    var temp1 = Venue(), temp2 = Venue(), temp3 = Venue(), temp4 = Venue(), temp5 = Venue()
    func initialize_things(){
        temp1.distance = miles_example[0]; temp1.venue_name = spots_example[0]
        temp2.distance = miles_example[1]; temp2.venue_name = spots_example[1]
        temp3.distance = miles_example[2]; temp3.venue_name = spots_example[2]
        temp4.distance = miles_example[3]; temp4.venue_name = spots_example[3]
        //temp5.distance = miles_example[4]; temp5.venue_name = spots_example[4]
        try1.append(temp1); try1.append(temp2); try1.append(temp3); try1.append(temp4)//; try1.append(temp5)
        print("after initialization")
        print(try1)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return A_to_Z.count
    }
    override func viewDidLoad() {
        initialize_things()
        super.viewDidLoad()
        //fill in the venue dictionary
        for many in try1{
            let spot_key = String(many.venue_name!.prefix(1))
            if var venue_values = venue_dictionary[spot_key]{
                venue_values.append(many)
                venue_dictionary[spot_key] = venue_values
            } else{
                venue_dictionary[spot_key] = [many]
            }
        }
        //sort the dictionary keys in alphabetical order
        A_to_Z = [String] (venue_dictionary.keys)
        A_to_Z = A_to_Z.sorted(by: { $0 < $1 })
        //self.tableView.reloadData()
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VenueTableCell")
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let venue_key = A_to_Z[section]
        if let vee = venue_dictionary[venue_key]{
            return vee.count
        }
        return 0;
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // event handler when a cell is tapped
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableCell", for: indexPath) as? VenueTableCell
        print("dictionary")
        print(venue_dictionary)
        print("key values")
        print(A_to_Z)
        print(try1)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableCell", for: indexPath) as? VenueTableCell else {
            fatalError("No reusable cell!")
        }
        let temp_venues = try1[indexPath.row]
        print("Problematic!!!")
        print(temp_venues)
        cell.name_venue.text = temp_venues.venue_name
        cell.name_venue.sizeToFit()
        cell.distance.text = temp_venues.distance
        cell.distance.sizeToFit()
        return cell;
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return A_to_Z;
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return A_to_Z[section]
    }
    
}
