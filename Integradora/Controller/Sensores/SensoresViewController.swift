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
        print("Realizando solicitud al servidor...")

        let url = URL(string: "http://3.129.244.114/api/datos")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["email": "alansasuke0@gmail.com"]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error al convertir los parámetros a JSON.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            // Mover la verificación de 'response' al principio
            guard let httpResponse = response as? HTTPURLResponse, let data = data, error == nil else {
                print("Error al obtener datos del servidor.")
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                // Respuesta exitosa (código de estado 2xx)
                print("Respuesta del servidor fue exitosa (Código \(httpResponse.statusCode)).")
            } else {
                // Respuesta con error
                print("Error en la respuesta del servidor (Código \(httpResponse.statusCode)).")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

                if let dataDict = json["data"] as? [String: Any], let dataArray = dataDict["data"] as? [[String: Any]], let primerSensorData = dataArray.first, let datos = primerSensorData["data"] as? [[String: Any]] {
                    
                    var ultimoSensorPorTipo: [String: Sensor] = [:]

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
        print("Limpiando la interfaz...")
        // Remover todas las subvistas de srcSensores para limpiar la interfaz
        for subview in self.srcSensores.subviews {
            subview.removeFromSuperview()
        }
    }

    
    func dibujarSensores() {
        print("Dibujando sensores...")
        // Define the desired order
        let order = ["DIS", "ST", "SH", "SM", "SS"]

        // Filter and sort the sensors based on the desired order
        let sensoresOrdenados = sensorTemperatura.filter { order.contains($0.tipo) }.sorted { sensor1, sensor2 in
            guard let index1 = order.firstIndex(of: sensor1.tipo), let index2 = order.firstIndex(of: sensor2.tipo) else {
                return false
            }
            return index1 < index2
        }

        // Limpia la interfaz antes de agregar las nuevas vistas
        limpiarInterfaz()

        var y = 10

        // Crea y agrega las vistas para el último sensor de cada tipo
        for sensor in sensoresOrdenados {
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
            nombreLabel.text = sensor.nSensor
            nombreLabel.font = .boldSystemFont(ofSize: 20)
            nombreLabel.textColor = .black
            vista.addSubview(nombreLabel)

            // Valor del sensor
            let dato = UILabel(frame: CGRect(x: 100, y: 35, width: Int(vista.frame.width) - 105, height: 60))
            dato.text = sensor.valor
            dato.font = .boldSystemFont(ofSize: 50)
            dato.textAlignment = .center
            dato.adjustsFontSizeToFitWidth = true
            dato.minimumScaleFactor = 0.5
            vista.addSubview(dato)

            // Unidades del sensor
            let unidades = UILabel(frame: CGRect(x: Int(vista.frame.width) - 100, y: 100, width: 90, height: 25))
            unidades.text = sensor.tipo
            unidades.font = .systemFont(ofSize: 15)
            unidades.textAlignment = .right
            vista.addSubview(unidades)

            // Fecha y hora del sensor
            let fechaHoraLabel = UILabel(frame: CGRect(x: 100, y: 130, width: Int(vista.frame.width) - 105, height: 25))
            if let fechaSensor = sensor.fecha {
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
            boton.tag = sensorTemperatura.firstIndex(of: sensor) ?? 0
            boton.addTarget(self, action: #selector(mostrarDetalle(sender:)), for: .touchDown)
            vista.addSubview(boton)

            srcSensores.addSubview(vista)
            y += 170 // Ajusta la altura total de la vista
        }

        srcSensores.contentSize = CGSize(width: 0, height: y)
    }

        

    
    @objc func mostrarDetalle(sender: UIButton) {
        let selectedSensor = sensorTemperatura[sender.tag]
        self.performSegue(withIdentifier: "sgSensoresAll", sender: selectedSensor)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgSensoresAll" {
            if let destinationVC = segue.destination as? SensoresAllViewController, let selectedSensor = sender as? Sensor {
                destinationVC.selectedSensor = selectedSensor
            }
        }
    }

}



