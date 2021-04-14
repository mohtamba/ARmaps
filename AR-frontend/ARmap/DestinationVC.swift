import UIKit
import Foundation


class DestinationVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var venueTitle: UILabel!
    @IBOutlet weak var destinationList: UITableView!
    var venue: Location?
    var lati = 0.0, longi = 0.0
    var selectedDestination = Location()
    let refreshControl = UIRefreshControl()

    //to create a dictionary of arrays
    var destination_dictionary = [String: [Location]]()
    var try1 = [Location]()
    var A_to_Z = [String]()
    var zero_to_five:[String] = ["0~1 mile","1~2 mile","2~3 mile","3~4 mile","4~5 mile","5+ mile"]
    var venue_dictionary2 = [String: [Location]]()
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return zero_to_five.count
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
        
//        for many in try1{
//            let spot_key = String(many.name.prefix(venueId))
//            if var dest_values = destination_dictionary[spot_key]{
//                dest_values.append(many)
//                destination_dictionary[spot_key] = dest_values
//            } else{
//                destination_dictionary[spot_key] = [many]
//            }
//        }
        for many in try1{
            var spot_key2 = "0~1 mile"
            if(many.distance! >= 1.0 && many.distance! < 2.0){
                spot_key2 = "1~2 mile"
            }else if(many.distance! >= 2.0 && many.distance! < 3.0){
                spot_key2 = "2~3 mile"
            }else if(many.distance! >= 3.0 && many.distance! < 4.0){
                spot_key2 = "3~4 mile"
            }else if(many.distance! >= 4.0 && many.distance! < 5.0){
                spot_key2 = "4~5 mile"
            }else if(many.distance! >= 5.0){
                spot_key2 = "5+ mile"
            }
            if var venue_values = venue_dictionary2[spot_key2]{
                venue_values.append(many)
                venue_dictionary2[spot_key2] = venue_values
            } else{
                venue_dictionary2[spot_key2] = [many]
            }
        }
        //fill in the venue dictionary
        //sort the dictionary keys in alphabetical order
//        A_to_Z = [String] (destination_dictionary.keys)
//        A_to_Z = A_to_Z.sorted(by: { $0 < $1 })
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
        
        store.get_destination_by_Venues_distance(venueId: venueId, lati: lati, longi: longi,refresh: { destinations in
            //print(destinations)
            self.try1 = destinations
            print(self.try1)
            DispatchQueue.main.async {
                self.destination_dictionary.removeAll()
                self.venue_dictionary2.removeAll()
                for many in self.try1{
                    var spot_key2 = "0~1 mile"
                    if(many.distance! >= 1.0 && many.distance! < 2.0){
                        spot_key2 = "1~2 mile"
                    }else if(many.distance! >= 2.0 && many.distance! < 3.0){
                        spot_key2 = "2~3 mile"
                    }else if(many.distance! >= 3.0 && many.distance! < 4.0){
                        spot_key2 = "3~4 mile"
                    }else if(many.distance! >= 4.0 && many.distance! < 5.0){
                        spot_key2 = "4~5 mile"
                    }else if(many.distance! >= 5.0){
                        spot_key2 = "5+ mile"
                    }
                    if var venue_values = self.venue_dictionary2[spot_key2]{
                        venue_values.append(many)
                        self.venue_dictionary2[spot_key2] = venue_values
                    } else{
                        self.venue_dictionary2[spot_key2] = [many]
                    }
                }
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
        let venue_key2 = zero_to_five[section]
        if let vee = venue_dictionary2[venue_key2]{
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
        let venue_key2 = zero_to_five[indexPath.section]
        let vee = venue_dictionary2[venue_key2]
        let temp_venues = vee![indexPath.row]
        cell.destination.text = temp_venues.name
        cell.destination.sizeToFit()
        return cell;
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return ["0","1","2","3","4","5"];
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return zero_to_five[section]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DescriptionVC {
            dest.dest = selectedDestination

            dest.venueId = venue?.id
        }
    }
}

