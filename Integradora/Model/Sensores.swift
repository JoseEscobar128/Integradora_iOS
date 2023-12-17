import UIKit

class Sensor: NSObject {
    var tipo: String
    var nSensor: String
    var valor: String
    var fecha: Date?

    init?(data: [String: Any]) {
        guard
            let tipo = data["tipo"] as? String,
            let nSensor = data["nSensor"] as? String,
            let valor = data["valor"] as? String,
            let fechaString = data["fecha"] as? String
        else {
            return nil
        }

        self.tipo = tipo
        self.nSensor = nSensor
        self.valor = valor

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.fecha = dateFormatter.date(from: fechaString)
    }

    override var description: String {
        let fechaString: String
        if let fecha = fecha {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            fechaString = dateFormatter.string(from: fecha)
        } else {
            fechaString = "Fecha desconocida"
        }

        return String(format: "Tipo: %@\nSensor: %@\nValor: %@\nFecha: %@", tipo, nSensor, valor, fechaString)
    }
}

