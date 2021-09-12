//
//  CarsTableViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    var cars: [Car] = []
    
    var label: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = UIColor(named: "main")
            return label
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        label.text = "Carregando carros..."
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func loadData() {
        REST.loadCars(onComplete: { (cars) in
                 
            self.cars = cars
         
            DispatchQueue.main.async {
                self.label.text = "Não existem carros cadastrados."
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
         
         
        }) { (error) in
         
            var response: String = ""
         
            switch error {
            case .invalidJSON:
                response = "Resposta inválida"
            case .noData:
                response = "Sem dados"
            case .responseError:
                response = "Algum problema com o servidor. :("
            }
            
            DispatchQueue.main.async {
                self.showAlert(withTitle: "Carregar carros", withMessage: response, isTryAgain: true, operation: .load_cars)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let count = cars.count
        
        if cars.count == 0 {
            // mostrar mensagem padrao
//            self.label.text = "Sem dados"
            self.tableView.backgroundView = self.label
        } else {
            self.tableView.backgroundView = nil
        }

        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            // Configure the cell...
            let car = cars[indexPath.row]
            cell.textLabel?.text = car.name
            cell.detailTextLabel?.text = car.brand
            return cell
        }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    // Delete the row from the data source
            let car = cars[indexPath.row]
            REST.delete(car: car) { () in
                // ATENCAO nao esquecer disso
                self.cars.remove(at: indexPath.row)
             
                DispatchQueue.main.async {
                    // Delete the row from the data source
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } onError: { error in
                print(error)
            }

        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewSegue" {
            let vc = segue.destination as? CarViewController
            if let index = tableView.indexPathForSelectedRow?.row {
                vc?.car = cars[index]
            }
        }
        
        
    }
    
    func showAlert(withTitle titleMessage: String, withMessage message: String, isTryAgain hasRetry: Bool, operation oper: CarOperationAction) {
     
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: .actionSheet)
     
        if hasRetry {
            let tryAgainAction = UIAlertAction(title: "Tentar novamente", style: .default, handler: {(action: UIAlertAction) in
             
                if oper == .load_cars {
                    self.loadData()
                }
             
            })
            alert.addAction(tryAgainAction)
         
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {(action: UIAlertAction) in
                DispatchQueue.main.async {
                    self.label.text = message
                    self.tableView.backgroundView = self.label
                }
            })
            alert.addAction(cancelAction)
        }
     
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
