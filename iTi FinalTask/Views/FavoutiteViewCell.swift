//
//  FavoutiteViewCell.swift
//  Storek 
//
//  Created by Abdelrahman Shera on 31/08/2023.
//

import UIKit

class FavoutiteViewCell: UITableViewCell {

    @IBOutlet weak var favouriteProductImage: UIImageView!
    @IBOutlet weak var favouriteProductName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
