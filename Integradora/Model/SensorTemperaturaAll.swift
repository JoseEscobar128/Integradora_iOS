//
//  SensorTemperaturaAll.swift
//  Integradora
//
//  Created by Jose Escobar on 13/12/23.
//

import UIKit

class SensorTemperaturaAll: NSObject {
    
    var value = 0
    var unit = ""
    var fech = ""
    var hor = ""
    
    
    init(valor:Int, unidades:String, fecha:String, hora:String)
    {
        value = valor
        unit = unidades
        fech = fecha
        hor = hora
        

    }
    
   

}
