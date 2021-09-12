//
//  Car.swift
//  Carangas
//
//  Created by Paulo Menezes on 03/09/21.
//  Copyright © 2021 Eric Brito. All rights reserved.
//

class Car: Codable {
 
    var _id: String?
    var brand: String = ""
    var gasType: Int = 0
    var name: String = ""
    var price: Double = 0.0
 
    var gas: String {
        switch gasType {
            case 0:
                return "Flex"
            case 1:
                return "Álcool"
            default:
                return "Gasolina"
        }
    }
}

struct Brand: Codable {
    let nome: String
    let codigo: String
}
