//
//  REST.swift
//  Carangas
//
//  Created by Paulo Menezes on 03/09/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Foundation
import Alamofire

enum CarError {
    case noData
    case responseError
    case invalidJSON
}

enum RESTOperation {
    case save
    case update
    case delete
}

class REST {
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let urlFipe = "https://parallelum.com.br/fipe/api/v1/carros/marcas"

    static func save(car: Car, onComplete: @escaping () -> Void, onError: @escaping (CarError) -> Void) {
        applyOperation(car: car, operation: .post, onComplete: onComplete, onError: onError)
    }
    
    static func update(car: Car, onComplete: @escaping () -> Void, onError: @escaping (CarError) -> Void) {
        applyOperation(car: car, operation: .put, onComplete: onComplete, onError: onError)
    }
    
    class func delete(car: Car, onComplete: @escaping () -> Void, onError: @escaping (CarError) -> Void ) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete, onError: onError)
    }
    
    static func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        AF.request(basePath).responseJSON { response in
            switch (response.result) {
                case .success:
                do {
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    
                    let cars = try JSONDecoder().decode([Car].self, from: data)

                    // pronto para reter dados
                    onComplete(cars)
                } catch {
                      // algum erro ocorreu com os dados
                    onError(.invalidJSON)
                }
            case .failure:
                onError(.responseError)
            }
        }
    }
    
    private class func applyOperation(car: Car, operation: HTTPMethod , onComplete: @escaping () -> Void, onError: @escaping (CarError) -> Void) {
        let urlString = basePath + "/" + (car._id ?? "")

        AF.request(urlString, method: operation, parameters: car, encoder: JSONParameterEncoder.default).response { response in
            switch (response.result) {
            case .success:
                onComplete()
            case .failure:
                onError(.responseError)
            }
        }
    }
    
    class func loadBrands(onComplete: @escaping ([Brand]?) -> Void, onError: @escaping (CarError) -> Void) {
        AF.request(urlFipe).responseJSON { response in
            switch (response.result) {
                case .success:
                do {
                    guard let data = response.data else {
                        onError(.noData)
                        return
                    }
                    
                    let brands = try JSONDecoder().decode([Brand].self, from: data)

                    // pronto para reter dados
                    onComplete(brands)
                } catch {
                    onError(.invalidJSON)
                }
            case .failure:
                onError(.responseError)
            }
        }
    }
}
