//
//  AddConsoleViewController.swift
//  My Games
//
//  Created by Paulo Menezes on 12/09/21.
//

import UIKit
import Photos

class AddConsoleViewController: UIViewController {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var buttonCover: UIButton!
    @IBOutlet weak var buttonAdd: UIButton!
    
    var console: Console!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if console != nil {
            title = "Update console"
            buttonAdd.setTitle("Update", for: .normal)
            textFieldName.text = console.name
                     
            imageViewCover.image = console.cover as? UIImage
            
            if console.cover != nil {
                buttonCover.setTitle(nil, for: .normal)
            }
        }
    }
    
    @IBAction func onAddImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select cover", message: "Where do you want to choose the cover?", preferredStyle: .actionSheet)

        let libraryAction = UIAlertAction(title: "Photo library", style: .default, handler: {(action: UIAlertAction) in
          self.selectPicture(sourceType: .photoLibrary)
        })
        alert.addAction(libraryAction)

        let photosAction = UIAlertAction(title: "Photos album", style: .default, handler: {(action: UIAlertAction) in
          self.selectPicture(sourceType: .savedPhotosAlbum)
        })
        alert.addAction(photosAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
    
    func chooseImageFromLibrary(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.navigationBar.tintColor = UIColor(named: "main")

            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func selectPicture(sourceType: UIImagePickerController.SourceType) {
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                 
                    self.chooseImageFromLibrary(sourceType: sourceType)
                 
                } else {
                 
                    print("unauthorized -- TODO message")
                }
            })
        } else if photos == .authorized {
         
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }
    
    @IBAction func onSave(_ sender: UIButton) {
        if console == nil {
            console = Console(context: context)
        }
        
        console.name = textFieldName.text
        console.cover = imageViewCover.image
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddConsoleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    // tip. implementando os 2 protocols o evento sera notificando apos user selecionar a imagem
   
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
           
            // ImageView won't update with new image
            // bug fixed: https://stackoverflow.com/questions/42703795/imageview-wont-update-with-new-image
            DispatchQueue.main.async {
                self.imageViewCover.image = pickedImage
                self.imageViewCover.setNeedsDisplay()
                self.buttonCover.setTitle(nil, for: .normal)
                self.buttonCover.setNeedsDisplay()
            }
        }
       
        dismiss(animated: true, completion: nil)
       
    }
   
}
