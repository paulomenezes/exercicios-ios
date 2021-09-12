//
//  AddEditViewController.swift
//  My Games
//
//  Created by Paulo Menezes on 21/08/21.
//

import UIKit
import Photos

class AddEditViewController: UIViewController {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldConsole: UITextField!
    @IBOutlet weak var datePickerRelease: UIDatePicker!
    
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var buttonCover: UIButton!
    
    @IBOutlet weak var buttonAddEdit: UIButton!
    
    var game: Game!
    private var consolesManager = ConsolesManager.shared
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .white
        
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        consolesManager.loadConsoles(with: context)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareDataLayout()
    }
    
    func prepareDataLayout() {
        if game != nil {
            title = "Update game"
            buttonAddEdit.setTitle("Update", for: .normal)
            textFieldName.text = game.title
         
            // tip. alem do console pegamos o indice atual para setar o picker view
            if let console = game.console, let index = consolesManager.consoles.firstIndex(of: console) {
                textFieldConsole.text = console.name
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            
            imageViewCover.image = game.cover as? UIImage
            
            if let releaseDate = game.releaseDate {
                datePickerRelease.date = releaseDate
            }
            
            if game.cover != nil {
                buttonCover.setTitle(nil, for: .normal)
            }
        }
     
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let buttonCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let buttonDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let buttonFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [buttonCancel, buttonFlexibleSpace, buttonDone]
     
        // tip. faz o text field exibir os dados predefinidos pela picker view
        textFieldConsole.inputView = pickerView
        textFieldConsole.inputAccessoryView = toolbar
    }
    
    @objc func cancel() {
       textFieldConsole.resignFirstResponder()
   }

   @objc func done() {
       textFieldConsole.text = consolesManager.consoles[pickerView.selectedRow(inComponent: 0)].name
       cancel()
   }
    
    @IBAction func onAddCover(_ sender: UIButton) {
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
        if game == nil {
            game = Game(context: context)
        }
        
        game.title = textFieldName.text
        game.releaseDate = datePickerRelease.date
        
        if !textFieldConsole.text!.isEmpty {
            let console = consolesManager.consoles[pickerView.selectedRow(inComponent: 0)]
            game.console = console
        }
        
        game.cover = imageViewCover.image
        
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

extension AddEditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
 
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return consolesManager.consoles.count
    }
 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let console = consolesManager.consoles[row]
        return console.name
    }
}

extension AddEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
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
