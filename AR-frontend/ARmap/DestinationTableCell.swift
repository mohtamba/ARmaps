

import UIKit

class DestinationTableCell: UITableViewCell {
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var destination: UILabel!
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
