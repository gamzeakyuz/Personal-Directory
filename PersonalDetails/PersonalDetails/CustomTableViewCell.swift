//
//  CustomTableViewCell.swift
//  PersonalDetails
//
//  Created by Gamze Akyüz on 27.08.2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var pnumberLabel: UILabel!
    @IBOutlet weak var epostaLabel: UILabel!
    @IBOutlet weak var mdetailsLabel: UILabel!
    
    @IBOutlet weak var lineLabel: UILabel!

    @IBOutlet weak var favButton: UIButton!
    
    var favoriteButtonTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        favButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        
        favButton.tintColor = UIColor.blue
        favButton.setImage(UIImage(systemName: "star"), for: .selected)
        favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func favoriteButtonPressed() {
            favoriteButtonTapped?()
        }
}
