import UIKit
import Foundation


class DestinationVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var destinationList: UITableView!
    var venueName: String?
    let refreshControl = UIRefreshControl()

    //to create a dictionary of arrays
    var destination_dictionary = [String: [Location]]()
    var try1 = [Location]()
    var A_to_Z = [String]()
    //add dumb venues--> to be deleted afterwards
    var spots_example = ["Hogwarts", "Olivanders", "Diagon Alley", "Platform 3/4", "Hogwarts Express","Azkeban"]
    var temp1 = Location(), temp2 = Location(), temp3 = Location(), temp4 = Location(), temp5 = Location(), temp6 = Location()
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

        /* add refresh control for reloading data */
        //refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        refreshControl.addTarget(self, action: #selector(DestinationVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)

        refreshTimeline()
        
        self.destinationList.delegate = self
        self.destinationList.dataSource = self
        self.destinationList.reloadData()
        venueTitle.text = venueName
        venueTitle.sizeToFit()
        print(try1)
        print("after dest refresh")
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
        store.get_destination_by_Venues(refresh: { destinations in
            print(destinations)
            self.try1 = destinations
            DispatchQueue.main.async {
                self.destination_dictionary.removeAll()
                for many in self.try1{
                    let spot_key = String(many.name!.prefix(1))
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
            // event handler when a cell is tapped
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueTableCell", for: indexPath) as? VenueTableCell
        print("dictionary")
        print(destination_dictionary)
        print("key values")
        print(A_to_Z)
        print(try1)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTableCell", for: indexPath) as? DestinationTableCell else {
            fatalError("No reusable cell!")
        }
        let venue_key = A_to_Z[indexPath.section]
        let vee = destination_dictionary[venue_key]
        //let temp_venues = try1[indexPath.row]
        print("Problematic!!!")
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
    
}

