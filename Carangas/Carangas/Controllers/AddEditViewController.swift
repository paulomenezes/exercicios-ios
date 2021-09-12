//
//  AddEditViewController.swift
//  Carangas
//
//  Created by Eric Brito.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

enum CarOperationAction {
    case load_cars
    case add_car
    case edit_car
    case get_brands
}

class AddEditViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var car: Car!
    var brands: [Brand] = []

    lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .white
        picker.delegate = self
//        picker.dataSource = sef
        
        return picker
    }()

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if car != nil {
            tfName.text = car.name
            tfBrand.text = car.brand
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType
            btAddEdit.setTitle("Alterar carro", for: .normal)
        }
        
        // 1 criamos uma toolbar e adicionamos como input do textview
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.tintColor = UIColor(named: "main")
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [btCancel, btSpace, btDone]
     
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerView
        
        loadBrands()

    }
    
    func showAlert(withTitle titleMessage: String, withMessage message: String, isTryAgain hasRetry: Bool, operation oper: CarOperationAction) {
        if oper != .get_brands {
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
            }
         
        }
     
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
     
        if hasRetry {
            let tryAgainAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: {(action: UIAlertAction) in
             
                switch oper {
                    case .add_car:
                        self.save()
                    case .edit_car:
                        self.update()
                    case .get_brands:
                        self.loadBrands()
                    case .load_cars:
                        print("loar cars")
                }
             
            })
            alert.addAction(tryAgainAction)
         
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action: UIAlertAction) in
                self.goBack()
            })
            alert.addAction(cancelAction)
        }
     
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBActions
    fileprivate func save() {
        startLoadingAnimation()
        
        REST.save(car: car) {
            self.goBack()
        } onError: { error in
            DispatchQueue.main.async {
                self.showAlert(withTitle: "Adicionar", withMessage: "Não foi possível salvar o carro!", isTryAgain: true, operation: .add_car)
            }
        }
    }
    
    fileprivate func update() {
        startLoadingAnimation()
        
        REST.update(car: car) {
            self.goBack()
        } onError: { error in
            DispatchQueue.main.async {
                self.showAlert(withTitle: "Atualizar", withMessage: "Não foi possível atualizar o carro!", isTryAgain: true, operation: .edit_car)
            }
        }
    }
    
    @IBAction func addEdit(_ sender: UIButton) {
        if car == nil {
            // adicionar carro novo
            car = Car()
        }
     
        if let name = tfName.text, let brand = tfBrand.text, name.count > 0 && brand.count > 0 {
            car.name = name
            car.brand = brand
            
            if tfPrice.text!.isEmpty {
                tfPrice.text = "0"
            }
            
            car.price = Double(tfPrice.text!)!
            car.gasType = scGasType.selectedSegmentIndex
       
            if car._id == nil {
                save()
           } else {
                update()
           }
        }
    }
    
    func goBack() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func loadBrands() {
        startLoadingAnimation()
        
        REST.loadBrands { (brands) in
            guard let brands = brands else {return}
         
            // ascending order
            self.brands = brands.sorted(by: {$0.nome < $1.nome})
         
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
                self.stopLoadingAnimation()
            }
        } onError: { error in
            DispatchQueue.main.async {
                self.showAlert(withTitle: "Marcas", withMessage: "Não foi possível carregar marcas!", isTryAgain: true, operation: .get_brands)
            }
        }
    }

    @objc func cancel() {
        tfBrand.resignFirstResponder()
    }
 
    @objc func done() {
        tfBrand.text = brands[pickerView.selectedRow(inComponent: 0)].nome
        cancel()
    }
    
    func startLoadingAnimation() {
        self.btAddEdit.isEnabled = false
        self.btAddEdit.backgroundColor = .gray
        self.btAddEdit.alpha = 0.5
        self.loading.startAnimating()
    }
 
    func stopLoadingAnimation() {
        self.btAddEdit.isEnabled = true
        self.btAddEdit.backgroundColor = UIColor(named: "main")
        self.btAddEdit.alpha = 1
        self.loading.stopAnimating()
    }
}

extension AddEditViewController:UIPickerViewDelegate, UIPickerViewDataSource {
 
    // MARK: - UIPickerViewDelegate
 
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
     
        let brand = brands[row]
        return brand.nome
    }
 
 
    // MARK: - UIPickerViewDataSource
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
 
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
}
