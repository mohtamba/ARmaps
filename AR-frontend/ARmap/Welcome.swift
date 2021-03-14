import UIKit
import Foundation
/*Welcome list todo:
    1) add a button so that users can refresh to generate a new list
    2) maybe also show the list of venues in the map
    3) maybe allow users to search nearby venues (add a search window)
    4) refresh function to be added in MVP
*/

class Welcome: UITableViewController{
    //to create a dictionary of arrays
    var venue_dictionary = [String: [Location]]()
    var selectedVenue = Location()
    var try1 = [Location]()
    var A_to_Z = [String]()

    override func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return A_to_Z.count
    }
    override func viewDidLoad() {
        //initialize_things()
        super.viewDidLoad()
        //fill in the venue dictionary
        refreshControl?.addTarget(self, action: #selector(Welcome.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        refreshTimeline()
        print("after refresh")
        print(try1)
        for many in try1{
            let spot_key = String(many.name!.prefix(1))
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
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshTimeline()
        //print("after handle")
        //print(try1)
    }
    
    private func refreshTimeline() {
        let store = LocationStore()
        store.getVenues(refresh: { venues in
            self.try1 = venues
            DispatchQueue.main.async {
                self.venue_dictionary.removeAll()
                for many in self.try1{
                    let spot_key = String(many.name!.prefix(1))
                    if var venue_values = self.venue_dictionary[spot_key]{
                        venue_values.append(many)
                        self.venue_dictionary[spot_key] = venue_values
                    } else{
                        self.venue_dictionary[spot_key] = [many]
                    }
                }
                //sort the dictionary keys in alphabetical order
                self.A_to_Z = [String] (self.venue_dictionary.keys)
                self.A_to_Z = self.A_to_Z.sorted(by: { $0 < $1 })
                self.tableView.estimatedRowHeight = 140
                self.tableView.rowHeight = UITableView.automaticDimension
                self.tableView.reloadData()
            }
        }) {
            DispatchQueue.main.async {
                // stop the refreshing animation upon completion:
                self.refreshControl?.endRefreshing()
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return try1.count
        let venue_key = A_to_Z[section]
        if let vee = venue_dictionary[venue_key]{
            return vee.count
        }
        return 0;
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // event handler when a cell is tapped
            let venue_key = A_to_Z[indexPath.section]
            let vee = venue_dictionary[venue_key]
            selectedVenue = vee![indexPath.row]
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "showDestinations", sender: self)
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableCell", for: indexPath) as? VenueTableCell else {
            fatalError("No reusable cell!")
        }
        let venue_key = A_to_Z[indexPath.section]
        let vee = venue_dictionary[venue_key]
        let temp_venues = vee![indexPath.row]
        cell.name_venue.text = temp_venues.name
        cell.name_venue.sizeToFit()
        cell.distance.text = temp_venues.description
        cell.distance.sizeToFit()
        return cell;
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return A_to_Z;
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return A_to_Z[section]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DestinationVC {
            dest.venue = selectedVenue
            
        }
    }
    
}
