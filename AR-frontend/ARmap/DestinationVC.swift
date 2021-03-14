import UIKit
import Foundation


class DestinationVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var destinationList: UITableView!
    var venueName: String?
    //to create a dictionary of arrays
    var venue_dictionary = [String: [Venue]]()
    var try1 = [Venue]()
    var A_to_Z = [String]()
    //add dumb venues--> to be deleted afterwards
    var spots_example = ["Hogwarts", "Olivanders", "Diagon Alley", "Platform 3/4", "Hogwarts Express","Azkeban"]
    var temp1 = Venue(), temp2 = Venue(), temp3 = Venue(), temp4 = Venue(), temp5 = Venue(), temp6 = Venue()
    func initialize_things(){
        try1.append(temp1); try1.append(temp2); try1.append(temp3); try1.append(temp4); try1.append(temp5); try1.append(temp6)
        print("after initialization")
        print(try1)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return A_to_Z.count
    }
    override func viewDidLoad() {
        initialize_things()
        super.viewDidLoad()
        self.destinationList.delegate = self
        self.destinationList.dataSource = self
        self.destinationList.reloadData()
        venueTitle.text = venueName
        venueTitle.sizeToFit()
        //fill in the venue dictionary
        //sort the dictionary keys in alphabetical order
        A_to_Z = [String] (venue_dictionary.keys)
        A_to_Z = A_to_Z.sorted(by: { $0 < $1 })
        //self.tableView.reloadData()
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VenueTableCell")
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return try1.count
        let venue_key = A_to_Z[section]
        if let vee = venue_dictionary[venue_key]{
            return vee.count
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // event handler when a cell is tapped
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableCell", for: indexPath) as? VenueTableCell
        print("dictionary")
        print(venue_dictionary)
        print("key values")
        print(A_to_Z)
        print(try1)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTableCell", for: indexPath) as? DestinationTableCell else {
            fatalError("No reusable cell!")
        }
        let venue_key = A_to_Z[indexPath.section]
        let vee = venue_dictionary[venue_key]
        //let temp_venues = try1[indexPath.row]
        print("Problematic!!!")
        let temp_venues = vee![indexPath.row]
        cell.destination.text = temp_venues.venue_name
        cell.destination.sizeToFit()
        return cell;
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return A_to_Z;
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return A_to_Z[section]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ARView2 {
            //dest.lat = venue_dictionary[
            //dest.lon = venue_dictionary
            
        }
    }
    
}

