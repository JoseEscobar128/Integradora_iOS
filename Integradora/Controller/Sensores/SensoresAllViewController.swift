import UIKit

class SensoresAllViewController: UIViewController {

    @IBOutlet weak var srcSensores: UIScrollView!

    var sensorTemperatura: [Sensor] = []
    var selectedSensor: Sensor?
    
    let tipoNumeroMapping: [String: Int] = ["ST": 0, "SH": 1, "SS": 2, "SM": 3, "DIS": 4]

    override func viewDidLoad() {
        super.viewDidLoad()
        consultarServicio()

        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(consultarServicio), userInfo: nil, repeats: true)
    }

    @objc func consultarServicio() {
        print("Realizando solicitud al servidor...")

        guard let selectedSensor = selectedSensor else {
            print("No hay sensor seleccionado.")
            return
        }

        guard let numeroSensor = tipoNumeroMapping[selectedSensor.tipo] else {
            print("Tipo de sensor no válido: \(selectedSensor.tipo)")
            return
        }

        let urlString = "http://18.117.124.234/api/historico/\(numeroSensor)"
        let url = URL(string: urlString)!

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
            guard let httpResponse = response as? HTTPURLResponse, let data = data, error == nil else {
                print("Error al obtener datos del servidor.")
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                print("Respuesta del servidor fue exitosa (Código \(httpResponse.statusCode)).")

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON de la respuesta: \(jsonString)")
                }

            } else {
                print("Error en la respuesta del servidor (Código \(httpResponse.statusCode)).")
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

                if let dataDict = json["data"] as? [String: Any], let dataArray = dataDict["data"] as? [[String: Any]], let primerSensorData = dataArray.first, let datos = primerSensorData["data"] as? [[String: Any]] {

                    let datosSensorSeleccionado = datos.filter { data in
                        guard let tipo = data["tipo"] as? String else {
                            return false
                        }
                        return tipo == selectedSensor.tipo
                    }

                    let datosSensorSTOrdenados = datosSensorSeleccionado.sorted { data1, data2 in
                        guard let fecha1 = data1["fecha"] as? String, let fecha2 = data2["fecha"] as? String else {
                            return false
                        }
                        return fecha1 > fecha2
                    }

                    let ultimosDatosST = Array(datosSensorSTOrdenados.prefix(20))
                    let sensoresST = ultimosDatosST.compactMap { Sensor(data: $0) }

                    self.sensorTemperatura = sensoresST

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
        for subview in self.srcSensores.subviews {
            subview.removeFromSuperview()
        }
    }

    func dibujarSensores() {
        print("Dibujando sensores...")

        limpiarInterfaz()

        let order = ["DIS", "ST", "SH", "SM", "SS"]

        let sensoresOrdenados = sensorTemperatura.filter { order.contains($0.tipo) }.sorted { sensor1, sensor2 in
            guard let index1 = order.firstIndex(of: sensor1.tipo), let index2 = order.firstIndex(of: sensor2.tipo) else {
                return false
            }
            return index1 < index2
        }

        var y = 10

        for sensor in sensoresOrdenados {
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(srcSensores.frame.width) - 20, height: 150))
            vista.backgroundColor = UIColor(red: 135/255.0, green: 206/255.0, blue: 250/255.0, alpha: 1.0)
            vista.layer.cornerRadius = 10
            vista.layer.masksToBounds = true

            let imagen = UIImageView(frame: CGRect(x: 20, y: 30, width: 90, height: 90))
            imagen.image = obtenerImagenParaTipo(sensor.tipo)
            vista.addSubview(imagen)

            let tipoLabel = UILabel(frame: CGRect(x: 30, y: 5, width: Int(vista.frame.width), height: 25))
            tipoLabel.text = obtenerTextoParaTipo(sensor.tipo)
            tipoLabel.font = .boldSystemFont(ofSize: 20)
            tipoLabel.textAlignment = .center
            tipoLabel.textColor = .black
            vista.addSubview(tipoLabel)

            let dato = UILabel(frame: CGRect(x: 30, y: 45, width: Int(vista.frame.width), height: 60))
            dato.text = sensor.valor
            dato.font = .boldSystemFont(ofSize: 50)
            dato.textAlignment = .center
            dato.adjustsFontSizeToFitWidth = true
            dato.minimumScaleFactor = 0.5
            vista.addSubview(dato)

            let unidades = UILabel(frame: CGRect(x: Int(vista.frame.width) - 100, y: 100, width: 90, height: 25))
            unidades.text = obtenerUnidadesParaTipo(sensor.tipo)
            unidades.font = .systemFont(ofSize: 15)
            unidades.textAlignment = .right
            vista.addSubview(unidades)

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

            boton.layer.borderWidth = 1.0
            boton.layer.borderColor = UIColor.systemBlue.cgColor

            vista.addSubview(boton)

            srcSensores.addSubview(vista)
            y += 170
        }

        srcSensores.contentSize = CGSize(width: 0, height: y)
    }

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
        print("Tag del botón presionado:", selectedSensor)
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

