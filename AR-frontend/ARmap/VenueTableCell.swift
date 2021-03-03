import UIKit

class VenueTableCell: UITableViewCell {
    
    @IBOutlet weak var name_venue: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var GoButton: UIButton!
    
    //TODO: what happens after tappin the go button
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

