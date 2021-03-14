//
//  DescriptionVC.swift
//  ARmap
//
//  Created by Mohammad Tambawala on 3/13/21.
//

import UIKit
import SDWebImage

class DescriptionVC: UIViewController{
    var dest: Location?
    
    
    @IBOutlet weak var destinationName: UILabel!
    
    @IBOutlet weak var destinationDescription: UITextView!
    
    
    @IBOutlet weak var destinationImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageEnd = String((dest?.imageUrl)!)
        let imageUrl = "https://api.armaps.net\(imageEnd)"
        print(imageUrl)
        destinationImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "photo"), options: [.progressiveLoad])
        destinationName.text = dest?.name
        destinationName.sizeToFit()
        destinationDescription.text = dest?.description
        destinationDescription.sizeToFit()
        // Do any additional setup after loading the view.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ARView2 {
            dest.lat = self.dest?.lat
            dest.lon = self.dest?.lon
            
        }
    }
}
