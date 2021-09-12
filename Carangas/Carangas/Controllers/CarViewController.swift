//
//  CarViewController.swift
//  Carangas
//
//  Created by Eric Brito on 21/10/17.
//  Copyright © 2017 Eric Brito. All rights reserved.
//

import UIKit
import WebKit

class CarViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var lbBrand: UILabel!
    @IBOutlet weak var lbGasType: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var car: Car!

    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        title = car.name
        lbBrand.text = car.brand
        lbGasType.text = car.gas
        lbPrice.text = "\(car.price)"
        
        // Configurando um requisição simples e exibindo na WebKit
        let name = (car.name + "+" + car.brand).replacingOccurrences(of: " ", with: "+")
        let urlString = "https://www.google.com.br/search?q=\(name)&tbm=isch"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
     
        // permite usar usar gestos para navegar
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true // preview usando 3D touch
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(request)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? AddEditViewController
        vc?.car = car
    }
}

extension CarViewController: WKNavigationDelegate, WKUIDelegate {
 
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("stopLoading")
        loading.stopAnimating()
    }
 
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loading.stopAnimating()
    }
 
}
