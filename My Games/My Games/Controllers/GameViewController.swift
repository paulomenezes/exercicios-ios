//
//  GameViewController.swift
//  My Games
//
//  Created by Paulo Menezes on 21/08/21.
//

import UIKit

class GameViewController: UIViewController {
    var game: Game!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelConsole: UILabel!
    @IBOutlet weak var labelReleaseDate: UILabel!
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var imageViewConsole: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
            
        title = game.title
        
           labelName.text = game.title
           labelConsole.text = game.console?.name
        
           if let releaseDate = game.releaseDate {
               let formatter = DateFormatter()
               formatter.dateStyle = .long
               formatter.locale = Locale(identifier: "en-US")
               labelReleaseDate.text = "Release date: " + formatter.string(from: releaseDate)
           }
        
           if let image = game.cover as? UIImage {
               imageViewCover.image = image
           } else {
               imageViewCover.image = UIImage(named: "noCoverFull")
           }
        
            if let image = game.console?.cover as? UIImage {
                imageViewConsole.image = image
            } else {
                imageViewCover.image = UIImage(named: "noCoverFull")
            }

       }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addEditViewController = segue.destination as! AddEditViewController
        addEditViewController.game = game
    }
    

}
