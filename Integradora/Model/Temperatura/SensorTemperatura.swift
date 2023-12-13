//
//  Sensor.swift
//  Integradora
//
//  Created by Jose Escobar on 12/12/23.
//

import UIKit

class SensorTemperatura: NSObject {
    
    
    var value = 0
    var unit = ""
    let nombre = "Sensor Temperatura"
    
    
    init(valor:Int, unidades:String)
    {
        value = valor
        unit = unidades
        

    }
    
    override var description: String
    {
        return String(format: "Valor: %@\nUnidades: %@", value, unit)
    }

}
