//
//  GameTableViewCell.swift
//  My Games
//
//  Created by Paulo Menezes on 21/08/21.
//

import UIKit

class GameTableViewCell: UITableViewCell {
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelConsole: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepare(with game: Game) {
        labelName.text = game.title ?? ""
        labelConsole.text = game.console?.name ?? ""
        
        if let image = game.cover as? UIImage {
            imageViewCover.image = image
        } else {
            imageViewCover.image = UIImage(named: "noCover")
        }
    }

}
