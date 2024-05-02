//
//  CustomTableViewCell.swift
//  Storek 
//
//  Created by Abdelrahman Shera on 28/08/2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ImageView.layer.cornerRadius = ImageView.frame.size.width / 2
        ImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
