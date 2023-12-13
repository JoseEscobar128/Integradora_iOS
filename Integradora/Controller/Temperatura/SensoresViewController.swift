//
//  ViewController.swift
//  Integradora
//
//  Created by Jose Escobar on 12/12/23.
//

import UIKit

class SensoresViewController: UIViewController {

    @IBOutlet weak var srcSensores: UIScrollView!
    
    var sensorTemperatura:[SensorTemperatura] = []
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        consultarServicio()
        // Configura un temporizador que llamará a la función consultarServicio cada 30 segundos
                Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(consultarServicio), userInfo: nil, repeats: true)
    }

    @objc func consultarServicio() {
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "http://127.0.0.1:8000/api/feeds/temperatura/1")!

        conexion.dataTask(with: url) { datos, respuesta, error in
            do {
                if let datos = datos {
                    let json = try JSONSerialization.jsonObject(with: datos) as! [String: Any]
                    let responseData = json["data"] as? [String: Any] ?? [:]

                    // Extraer información del sensor de temperatura
                    if let valor = responseData["valor"] as? Int,
                       let unidades = responseData["unidades"] as? String {
                        // Crear instancia de SensorTemperatura
                        let sensor = SensorTemperatura(valor: valor, unidades: unidades)

                        // Reemplazar la lista existente con el nuevo sensor
                        self.sensorTemperatura = [sensor]

                        DispatchQueue.main.async {
                            // Limpiar la interfaz de usuario antes de volver a dibujar
                            self.limpiarInterfaz()
                            // Llamar a la función para dibujar después de obtener la respuesta
                            self.dibujarPersonajes()
                        }
                    } else {
                        print("Datos incompletos en la respuesta.")
                    }
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

    
    func dibujarPersonajes() {
        var y = 10

        for i in 0..<sensorTemperatura.count {
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(srcSensores.frame.width) - 20, height: 130))
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
            nombreLabel.text = sensorTemperatura[i].nombre
            nombreLabel.font = .boldSystemFont(ofSize: 20)
            nombreLabel.textColor = .black
            vista.addSubview(nombreLabel)

            // Valor del sensor
            let dato = UILabel(frame: CGRect(x: 100, y: 35, width: Int(vista.frame.width) - 105, height: 60))
            dato.text = String(sensorTemperatura[i].value)
            dato.font = .boldSystemFont(ofSize: 50)
            dato.textAlignment = .center
            dato.adjustsFontSizeToFitWidth = true
            dato.minimumScaleFactor = 0.5
            vista.addSubview(dato)

            // Unidades del sensor
            let unidades = UILabel(frame: CGRect(x: Int(vista.frame.width) - 100, y: 100, width: 90, height: 25))
            unidades.text = sensorTemperatura[i].unit
            unidades.font = .systemFont(ofSize: 20)
            unidades.textAlignment = .right
            vista.addSubview(unidades)
            
            let boton = UIButton(frame: CGRect(x: 0, y: 0, width: vista.frame.width, height: vista.frame.height))
            boton.tag = i
            boton.addTarget(self, action: #selector(mostrarDetalle(sender:)), for: .touchDown)
            vista.addSubview(boton)

            srcSensores.addSubview(vista)
            y += 140
        }
        srcSensores.contentSize = CGSize(width: 0, height: y)
    }
    
    @objc func mostrarDetalle(sender: UIButton)
    {
        self.performSegue(withIdentifier: "sgTemperaturaAll", sender: sender)
    }


}

