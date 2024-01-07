//
//  ViewController.swift
//  Integradora
//
//  Created by Jose Escobar on 12/12/23.
//

import UIKit

class SensoresViewController: UIViewController {

    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var srcSensores: UIScrollView!
    
    var sensorTemperatura:[Sensor] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        consultarServicio()
        // Configura un temporizador que llamará a la función consultarServicio cada 30 segundos
                Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(consultarServicio), userInfo: nil, repeats: true)
    }

    @IBAction func btnSalir(_ sender: Any) {
        // Regresa a la pantalla principal
        performSegue(withIdentifier: "sgSalir", sender: nil)
        
    }
    
    
    @objc func consultarServicio() {
        print("Realizando solicitud al servidor...")

        let url = URL(string: "http://18.117.124.234/api/actual")!
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
                print("JSON de la respuesta:", json)

                if let responseData = json["data"] as? [String: Any], let dataArray = responseData["data"] as? [[String: Any]] {
                    var ultimoSensorPorTipo: [String: Sensor] = [:]

                    for data in dataArray {
                        if let sensorData = data["data"] as? [String: Any], let sensor = Sensor(data: sensorData), let fechaSensor = sensor.fecha {
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
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(srcSensores.frame.width) - 20, height: 150)) // Ajusta la altura para acomodar la fecha
            vista.backgroundColor = UIColor(red: 135/255.0, green: 206/255.0, blue: 250/255.0, alpha: 1.0)
            vista.layer.cornerRadius = 10
            vista.layer.masksToBounds = true

            // Imagen del sensor a la izquierda
            let imagen = UIImageView(frame: CGRect(x: 20, y: 30, width: 90, height: 90))
            imagen.image = obtenerImagenParaTipo(sensor.tipo)
            vista.addSubview(imagen)

            // Tipo del sensor centrado en la parte superior
            let tipoLabel = UILabel(frame: CGRect(x: 30, y: 5, width: Int(vista.frame.width), height: 25))
            tipoLabel.text = obtenerTextoParaTipo(sensor.tipo)
            tipoLabel.font = .boldSystemFont(ofSize: 20)
            tipoLabel.textAlignment = .center
            tipoLabel.textColor = .black
            vista.addSubview(tipoLabel)

            // Valor del sensor en el centro
            let dato = UILabel(frame: CGRect(x: 30, y: 45, width: Int(vista.frame.width), height: 60))
            dato.text = sensor.valor
            dato.font = .boldSystemFont(ofSize: 50)
            dato.textAlignment = .center
            dato.adjustsFontSizeToFitWidth = true
            dato.minimumScaleFactor = 0.5
            vista.addSubview(dato)

            // Unidades del sensor a la derecha
            let unidades = UILabel(frame: CGRect(x: Int(vista.frame.width) - 100, y: 100, width: 90, height: 25))
            unidades.text = obtenerUnidadesParaTipo(sensor.tipo)
            unidades.font = .systemFont(ofSize: 15)
            unidades.textAlignment = .right
            vista.addSubview(unidades)

            // Fecha y hora del sensor en la parte inferior
            let fechaHoraLabel = UILabel(frame: CGRect(x: 0, y: 130, width: Int(vista.frame.width), height: 25))
            if let fechaSensor = sensor.fecha {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                fechaHoraLabel.text = dateFormatter.string(from: fechaSensor)
            } else {
                fechaHoraLabel.text = "Fecha desconocida"
            }
            fechaHoraLabel.font = .systemFont(ofSize: 12)
            fechaHoraLabel.textColor = .gray
            fechaHoraLabel.textAlignment = .center
            vista.addSubview(fechaHoraLabel)

            let boton = UIButton(frame: CGRect(x: 0, y: 0, width: vista.frame.width, height: vista.frame.height))
            boton.tag = sensorTemperatura.firstIndex(of: sensor) ?? 0
            boton.addTarget(self, action: #selector(mostrarDetalle(sender:)), for: .touchDown)

            // Configurar el color del borde
            boton.layer.borderWidth = 1.0
            boton.layer.borderColor = UIColor.systemBlue.cgColor  

            vista.addSubview(boton)

            srcSensores.addSubview(vista)
            y += 170 // Ajusta la altura total de la vista
        }

        srcSensores.contentSize = CGSize(width: 0, height: y)
    }

    // Funciones auxiliares para obtener el texto, las unidades y la imagen según el tipo de sensor
    func obtenerTextoParaTipo(_ tipo: String) -> String {
        switch tipo {
        case "DIS":
            return "Sensor Distancia"
        case "ST":
            return "Sensor Temperatura"
        case "SH":
            return "Sensor Humedad"
        case "SM":
            return "Sensor Movimiento"
        case "SS":
            return "Sensor Sonido"
        default:
            return "Tipo Desconocido"
        }
    }

    func obtenerUnidadesParaTipo(_ tipo: String) -> String {
        // Puedes ajustar las unidades según tus necesidades
        switch tipo {
        case "DIS":
            return "cm"
        case "ST":
            return "°C"
        case "SH":
            return "%"
        case "SM":
            return "M"
        case "SS":
            return "D"
        default:
            return "Unidades Desconocidas"
        }
    }

    func obtenerImagenParaTipo(_ tipo: String) -> UIImage {
        // Puedes ajustar las imágenes según tus necesidades
        switch tipo {
        case "DIS":
            return UIImage(named: "distancia.png") ?? UIImage()
        case "ST":
            return UIImage(named: "temperatura.png") ?? UIImage()
        case "SH":
            return UIImage(named: "humedad.png") ?? UIImage()
        case "SM":
            return UIImage(named: "movimiento.png") ?? UIImage()
        case "SS":
            return UIImage(named: "sonido.png") ?? UIImage()
        default:
            return UIImage()
        }
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



