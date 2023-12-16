//
//  ViewController.swift
//  Integradora
//
//  Created by Jose Escobar on 12/12/23.
//

import UIKit

class SensoresViewController: UIViewController {

    @IBOutlet weak var srcSensores: UIScrollView!
    
    var sensorTemperatura:[Sensor] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        consultarServicio()
        // Configura un temporizador que llamará a la función consultarServicio cada 30 segundos
                Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(consultarServicio), userInfo: nil, repeats: true)
    }

    @objc func consultarServicio() {
        let url = URL(string: "http://3.129.244.114/api/datos")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["email": "alansasuke0@gmail.com"]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error converting parameters to JSON.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Algo salió mal =(")
                return
            }

            do {
                    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    //print("Respuesta JSON del servidor:", json)

                    if let dataDict = json["data"] as? [String: Any], let dataArray = dataDict["data"] as? [[String: Any]], let primerSensorData = dataArray.first, let datos = primerSensorData["data"] as? [[String: Any]] {
                        
                        // Crear un diccionario para almacenar el último sensor de cada tipo
                        var ultimoSensorPorTipo: [String: Sensor] = [:]

                        // Iterar sobre los datos y actualizar el diccionario con los últimos sensores
                        for data in datos {
                            if let sensor = Sensor(data: data), let fechaSensor = sensor.fecha {
                                if let ultimoSensor = ultimoSensorPorTipo[sensor.tipo] {
                                    if let fechaUltimoSensor = ultimoSensor.fecha, fechaSensor > fechaUltimoSensor {
                                        ultimoSensorPorTipo[sensor.tipo] = sensor
                                    }
                                } else {
                                    ultimoSensorPorTipo[sensor.tipo] = sensor
                                }
                            }
                        }

                        // Actualizar el arreglo de sensores con los últimos sensores por tipo
                        self.sensorTemperatura = Array(ultimoSensorPorTipo.values)

                        DispatchQueue.main.async {
                            self.limpiarInterfaz()
                            self.dibujarSensores()
                        }
                    } else {
                        print("Datos incompletos en la respuesta.")
                    }
                } catch {
                    print("Algo salió mal =(")
                }
        }.resume()
    }


    

    func limpiarInterfaz() {
        // Remover todas las subvistas de srcSensores para limpiar la interfaz
        for subview in self.srcSensores.subviews {
            subview.removeFromSuperview()
        }
    }

    
    func dibujarSensores() {
        var ultimoSensorPorTipo: [String: Sensor] = [:]

        for i in 0..<sensorTemperatura.count {
            let sensor = sensorTemperatura[i]

            // Verifica si ya tenemos un sensor de este tipo
            if let ultimoSensor = ultimoSensorPorTipo[sensor.tipo] {
                // Compara las fechas y actualiza si es más reciente
                if let fechaSensor = sensor.fecha, let fechaUltimoSensor = ultimoSensor.fecha, fechaSensor > fechaUltimoSensor {
                    ultimoSensorPorTipo[sensor.tipo] = sensor
                }
            } else {
                // Si no hay un sensor de este tipo, simplemente agrega el sensor actual
                ultimoSensorPorTipo[sensor.tipo] = sensor
            }
        }

        // Imprime los datos para depuración
        print("Diccionario de últimos sensores por tipo:")
        for (tipo, ultimoSensor) in ultimoSensorPorTipo {
            print("\(tipo): \(ultimoSensor)")
        }

        // Limpia la interfaz antes de agregar las nuevas vistas
        limpiarInterfaz()

        var y = 10

        // Crea y agrega las vistas para el último sensor de cada tipo
        for (_, ultimoSensor) in ultimoSensorPorTipo {
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(srcSensores.frame.width) - 20, height: 170)) // Ajusta la altura para acomodar la fecha
            vista.backgroundColor = UIColor(
                red: CGFloat(0xFC) / 255.0,
                green: CGFloat(0xF5) / 255.0,
                blue: CGFloat(0xC7) / 255.0,
                alpha: 1.0
            )
            vista.layer.cornerRadius = 10
            vista.layer.masksToBounds = true

            // Imagen del sensor en el lado izquierdo
            let imagen = UIImageView(frame: CGRect(x: 5, y: 5, width: 90, height: 90))
            imagen.image = UIImage(named: "loading.png")
            vista.addSubview(imagen)

            // Nombre del sensor
            let nombreLabel = UILabel(frame: CGRect(x: 100, y: 5, width: Int(vista.frame.width) - 105, height: 25))
            nombreLabel.text = ultimoSensor.nSensor
            nombreLabel.font = .boldSystemFont(ofSize: 20)
            nombreLabel.textColor = .black
            vista.addSubview(nombreLabel)

            // Valor del sensor
            let dato = UILabel(frame: CGRect(x: 100, y: 35, width: Int(vista.frame.width) - 105, height: 60))
            dato.text = ultimoSensor.valor
            dato.font = .boldSystemFont(ofSize: 50)
            dato.textAlignment = .center
            dato.adjustsFontSizeToFitWidth = true
            dato.minimumScaleFactor = 0.5
            vista.addSubview(dato)

            // Unidades del sensor
            let unidades = UILabel(frame: CGRect(x: Int(vista.frame.width) - 100, y: 100, width: 90, height: 25))
            unidades.text = ultimoSensor.tipo
            unidades.font = .systemFont(ofSize: 15)
            unidades.textAlignment = .right
            vista.addSubview(unidades)

            // Fecha y hora del sensor
            let fechaHoraLabel = UILabel(frame: CGRect(x: 100, y: 130, width: Int(vista.frame.width) - 105, height: 25))
            if let fechaSensor = ultimoSensor.fecha {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                fechaHoraLabel.text = dateFormatter.string(from: fechaSensor)
            } else {
                fechaHoraLabel.text = "Fecha desconocida"
            }
            fechaHoraLabel.font = .systemFont(ofSize: 12)
            fechaHoraLabel.textColor = .gray
            fechaHoraLabel.textAlignment = .right
            vista.addSubview(fechaHoraLabel)

            let boton = UIButton(frame: CGRect(x: 0, y: 0, width: vista.frame.width, height: vista.frame.height))
            boton.tag = sensorTemperatura.firstIndex(of: ultimoSensor) ?? 0
            boton.addTarget(self, action: #selector(mostrarDetalle(sender:)), for: .touchDown)
            vista.addSubview(boton)

            srcSensores.addSubview(vista)
            y += 170 // Ajusta la altura total de la vista
        }

        srcSensores.contentSize = CGSize(width: 0, height: y)
    }

        

    
    @objc func mostrarDetalle(sender: UIButton) {
           self.performSegue(withIdentifier: "sgTemperaturaAll", sender: sender)
       }
}



