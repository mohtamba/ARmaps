import UIKit
import Foundation


class DestinationVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var destinationList: UITableView!
    var venue: Location?
    var selectedDestination = Location()
    let refreshControl = UIRefreshControl()

    //to create a dictionary of arrays
    var destination_dictionary = [String: [Location]]()
    var try1 = [Location]()
    var A_to_Z = [String]()
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return A_to_Z.count
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        /* manually add refresh control for reloading data b/c non-TableViewController */
        refreshControl.addTarget(self, action: #selector(DestinationVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        refreshTimeline()
        
        self.destinationList.delegate = self
        self.destinationList.dataSource = self
        self.destinationList.reloadData()
        if let venueName = venue?.name {
            venueTitle.text = venueName
        }
        venueTitle.sizeToFit()
        
        guard let venueId = venue?.id else {
            print("venue missing id")
            return
        }
        
        for many in try1{
            let spot_key = String(many.name!.prefix(venueId))
            if var dest_values = destination_dictionary[spot_key]{
                dest_values.append(many)
                destination_dictionary[spot_key] = dest_values
            } else{
                destination_dictionary[spot_key] = [many]
            }
        }
        
        //fill in the venue dictionary
        //sort the dictionary keys in alphabetical order
        A_to_Z = [String] (destination_dictionary.keys)
        A_to_Z = A_to_Z.sorted(by: { $0 < $1 })
        //self.tableView.reloadData()
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VenueTableCell")
        
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshTimeline()
        print("after handle")
        print(try1)
    }
    
    private func refreshTimeline() {
        let store = LocationStore()
        
        guard let venueId = venue?.id else {
            print("venue missing id")
            return
        }
        
        store.get_destination_by_Venues(venueId: venueId, refresh: { destinations in
            //print(destinations)
            self.try1 = destinations
            print(self.try1)
            DispatchQueue.main.async {
                self.destination_dictionary.removeAll()
                for many in self.try1 {
                    let spot_key = String(many.name!.prefix(venueId))
                    if var destination_values = self.destination_dictionary[spot_key]{
                        destination_values.append(many)
                        self.destination_dictionary[spot_key] = destination_values
                    } else{
                        self.destination_dictionary[spot_key] = [many]
                    }
                }
                //sort the dictionary keys in alphabetical order
                self.A_to_Z = [String] (self.destination_dictionary.keys)
                self.A_to_Z = self.A_to_Z.sorted(by: { $0 < $1 })
                self.destinationList.reloadData()

            }
        }) {
            DispatchQueue.main.async {
                // stop the refreshing animation upon completion:
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return try1.count
        let venue_key = A_to_Z[section]
        if let vee = destination_dictionary[venue_key]{
            return vee.count
        }
        return 0;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dest_key = A_to_Z[indexPath.section]
        let vee = destination_dictionary[dest_key]
        selectedDestination = vee![indexPath.row]
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: "showDescription", sender: self)
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTableCell", for: indexPath) as? DestinationTableCell else {
            fatalError("No reusable cell!")
        }
        let venue_key = A_to_Z[indexPath.section]
        let vee = destination_dictionary[venue_key]
        //let temp_venues = try1[indexPath.row]
        let temp_venues = vee![indexPath.row]
        cell.destination.text = temp_venues.name
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
        if let dest = segue.destination as? DescriptionVC {
            dest.dest = selectedDestination

            dest.venueId = venue?.id
        }
    }
}

