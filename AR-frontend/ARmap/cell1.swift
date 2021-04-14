import UIKit

class cell1: UITableViewCell {
    
    
    
    @IBOutlet weak var name_venue1: UILabel!
    
    @IBOutlet weak var distance1: UILabel!
    
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
