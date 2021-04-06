import UIKit
import Foundation
class Attempt: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    
    //Action touched off by selection
    @IBAction func kitty(_ sender: Any) {
        mytable.reloadData()
    }
    @IBOutlet weak var mysegment: UISegmentedControl!
    @IBOutlet weak var mytable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //Old code
    var venue_dictionary = [String: [Location]]()
    var selectedVenue = Location()
    var try1 = [Location]()
    var A_to_Z = [String]()
    //var try2 = [Location]()
    var zero_to_five:[String] = ["0~1 mile","1~2 mile","2~3 mile","3~4 mile","4~5 mile","5+ mile"]
    //var zero_to_five = [Int](arrayLiteral: 0,1,2,3,4,5)
    var venue_dictionary2 = [String: [Location]]()
    var filtered_data: [Location]!
    
    let refreshControl = UIRefreshControl()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch(mysegment.selectedSegmentIndex){
        case 0:
            return A_to_Z.count
        case 1:
            return zero_to_five.count
        default:
            return 0
        }
    }
    override func viewDidLoad() {
        //initialize_things()
        super.viewDidLoad()
        
        //fill in the venue dictionary
        refreshControl.addTarget(self, action: #selector(Attempt.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        filtered_data = try1
        refreshTimeline()
        searchBar.delegate = self
        self.mytable.dataSource = self
        self.mytable.reloadData()
        print("after refresh")
        print(try1)
        for many in filtered_data{
            let spot_key = String(many.name.prefix(1))
            if var venue_values = venue_dictionary[spot_key]{
                venue_values.append(many)
                venue_dictionary[spot_key] = venue_values
            } else{
                venue_dictionary[spot_key] = [many]
            }
        }
        //TODO: another part
        for many in filtered_data{
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
        //sort the dictionary keys in alphabetical order
        print(zero_to_five)
        //Sort the dictionary keys in alphabetical order
        A_to_Z = [String] (venue_dictionary.keys)
        A_to_Z = A_to_Z.sorted(by: { $0 < $1 })
        
        
        //self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VenueTableCell")
        
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshTimeline()
    }
    
    private func refreshTimeline() {
        var store = LocationStore()
        store.getVenues(refresh: { venues in
            self.try1 = venues
            self.filtered_data = venues
            DispatchQueue.main.async {
                self.venue_dictionary.removeAll()
                self.venue_dictionary2.removeAll()
                for many in self.try1{
                    let spot_key = String(many.name.prefix(1))
                    if var venue_values = self.venue_dictionary[spot_key]{
                        venue_values.append(many)
                        self.venue_dictionary[spot_key] = venue_values
                    } else{
                        self.venue_dictionary[spot_key] = [many]
                    }
                }
                //TODO: another part
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
                //sort the dictionary keys in alphabetical order
                self.A_to_Z = [String] (self.venue_dictionary.keys)
                self.A_to_Z = self.A_to_Z.sorted(by: { $0 < $1 })
//                self.tableView.estimatedRowHeight = 140
//                self.tableView.rowHeight = UITableView.automaticDimension
                
                self.mytable.reloadData()
            }
        }) {
            DispatchQueue.main.async {
                // stop the refreshing animation upon completion:
                self.refreshControl.endRefreshing()
            }
        }
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of ... til here?")
        switch(mysegment.selectedSegmentIndex){
        case 0:
            let venue_key = A_to_Z[section]
            if let vee = venue_dictionary[venue_key]{
                return vee.count
            }
            return 0
        case 1:
            let venue_key2 = zero_to_five[section]
            if let vee = venue_dictionary2[venue_key2]{
                return vee.count
            }
            return 0
        default:
            return 0
        }
    }
    //To manipulate the two dictionaries on change of filtered_data
    func manipulate_library(){
        self.venue_dictionary.removeAll()
        self.venue_dictionary2.removeAll()
        for many in self.filtered_data{
            let spot_key = String(many.name.prefix(1))
            if var venue_values = self.venue_dictionary[spot_key]{
                venue_values.append(many)
                self.venue_dictionary[spot_key] = venue_values
            } else{
                self.venue_dictionary[spot_key] = [many]
            }
        }
        //TODO: another part
        for many in self.filtered_data{
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
        //sort the dictionary keys in alphabetical order
        self.A_to_Z = [String] (self.venue_dictionary.keys)
        self.A_to_Z = self.A_to_Z.sorted(by: { $0 < $1 })
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? cell1 else {
            fatalError("No reusable cell!")
        }
        print("cell for row at ... til here?")
        switch(mysegment.selectedSegmentIndex){
        case 0:
            let venue_key = A_to_Z[indexPath.section]
            let vee = venue_dictionary[venue_key]
            let temp_venues = vee![indexPath.row]
            cell.name_venue1.text = temp_venues.name
            cell.name_venue1.sizeToFit()
            cell.distance1.text = temp_venues.description
            cell.distance1.sizeToFit()
            return cell;
        case 1:
            let venue_key2 = zero_to_five[indexPath.section]
            let vee = venue_dictionary2[venue_key2]
            let temp_venues = vee![indexPath.row]
            cell.name_venue1.text = temp_venues.name
            cell.name_venue1.sizeToFit()
            cell.distance1.text = temp_venues.description
            cell.distance1.sizeToFit()
            return cell;
        default:
            return cell
        }
        
    }
     func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        switch(mysegment.selectedSegmentIndex){
        case 0:
            return A_to_Z;
        case 1:
            return ["0","1","2","3","4","5"];
        default:
            return A_to_Z;
        }
    }
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(mysegment.selectedSegmentIndex){
        case 0:
            return A_to_Z[section]
        case 1:
            return zero_to_five[section];
        default:
            return A_to_Z[section]
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DestinationVC {
            dest.venue = selectedVenue
        }
    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.endEditing(true)
//
//        self.filtered_data = self.try1
//        self.mytable.reloadData()
//    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
            filtered_data = []
            print("Searched text: ", searchText)
            if(searchText == ""){
                filtered_data = try1
            }else {
                for things in try1{
                    if things.name.lowercased().contains(searchText.lowercased()){
                        print("what included: ", things.name.lowercased())
                        //print("Success")
                        filtered_data.append(things)
                        print("Hi", searchText)
                    }
                }
                print(filtered_data.count)
            }
            manipulate_library()
            self.mytable.reloadData()
    }
//    //Search Bar Config
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
//        filtered_data = []
//        if(searchText == ""){
//            filtered_data = try1
//        }else {
//            for things in try1{
//                if ((things.name?.lowercased().contains(searchText.lowercased())) != nil){
//                    filtered_data.append(things)
//                }
//            }
//        }
//        self.mytable.reloadData()
//    }
}

