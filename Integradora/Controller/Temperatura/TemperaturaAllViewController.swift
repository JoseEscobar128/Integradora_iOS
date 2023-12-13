import UIKit

class TemperaturaAllViewController: UIViewController {

    @IBOutlet weak var srcTemperaturaAll: UIScrollView!
    var sensorTemperaturaAll: [SensorTemperaturaAll] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Llama a la función para consultar el servicio
        consultarServicio()

        // Configura un temporizador que llamará a la función consultarServicio cada 30 segundos
        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(consultarServicio), userInfo: nil, repeats: true)
    }

    @objc func consultarServicio() {
        let conexion = URLSession(configuration: .default)
        let url = URL(string: "http://127.0.0.1:8000/api/feeds/temperaturaAll")!

        conexion.dataTask(with: url) { datos, respuesta, error in
            do {
                if let datos = datos {
                    let json = try JSONSerialization.jsonObject(with: datos) as! [String: Any]
                    let responseData = json["data"] as? [[String: Any]] ?? []

                    // Convertir solo los primeros 20 registros a instancias de SensorTemperaturaAll
                    let registros = responseData.prefix(20).compactMap { registro -> SensorTemperaturaAll? in
                        if let valor = registro["valor"] as? Int,
                           let unidades = registro["unidades"] as? String,
                           let fecha = registro["fecha"] as? String,
                           let hora = registro["hora"] as? String {
                            return SensorTemperaturaAll(valor: valor, unidades: unidades, fecha: fecha, hora: hora)
                        }
                        return nil
                    }

                    // Reemplazar la lista existente con los nuevos registros
                    self.sensorTemperaturaAll = registros

                    DispatchQueue.main.async {
                        // Limpiar la interfaz de usuario antes de volver a dibujar
                        self.limpiarInterfaz()
                        // Llamar a la función para dibujar después de obtener la respuesta
                        self.dibujarPersonajes()
                    }
                }
            } catch {
                print("Algo salió mal =(")
            }
        }.resume()
    }


    func limpiarInterfaz() {
        // Remover todas las subvistas de srcTemperaturaAll para limpiar la interfaz
        for subview in self.srcTemperaturaAll.subviews {
            subview.removeFromSuperview()
        }
    }

    func dibujarPersonajes() {
        var y = 10

        for i in 0..<sensorTemperaturaAll.count {
            let vista = UIView(frame: CGRect(x: 10, y: y, width: Int(srcTemperaturaAll.frame.width) - 20, height: 180))
            vista.backgroundColor = UIColor(
                red: CGFloat(0xFC) / 255.0,
                green: CGFloat(0xF5) / 255.0,
                blue: CGFloat(0xC7) / 255.0,
                alpha: 1.0
            )
            vista.layer.cornerRadius = 10
            vista.layer.masksToBounds = true

            // Imagen del sensor en el lado izquierdo
            let imagen = UIImageView(frame: CGRect(x: 10, y: 10, width: 90, height: 90))
            imagen.image = UIImage(named: "loading.png") // ¡Reemplaza "loading.png" con el nombre de tu imagen!
            vista.addSubview(imagen)

            // Valor del sensor en negritas y grande
            let dato = UILabel(frame: CGRect(x: 110, y: 10, width: Int(vista.frame.width) - 120, height: 60))
            dato.text = String(sensorTemperaturaAll[i].value)
            dato.font = .boldSystemFont(ofSize: 60)
            dato.textAlignment = .center
            dato.textColor = .black
            vista.addSubview(dato)

            // Unidades del sensor al lado del valor
            let unidades = UILabel(frame: CGRect(x: 110, y: 70, width: Int(vista.frame.width) - 120, height: 30))
            unidades.text = sensorTemperaturaAll[i].unit
            unidades.font = .systemFont(ofSize: 25)
            unidades.textAlignment = .center
            unidades.textColor = .black
            vista.addSubview(unidades)

            // Línea separadora
            let linea = UIView(frame: CGRect(x: 10, y: 110, width: Int(vista.frame.width) - 20, height: 1))
            linea.backgroundColor = .white
            vista.addSubview(linea)

            // Etiqueta "Fecha:"
            let etiquetaFecha = UILabel(frame: CGRect(x: 10, y: 115, width: 60, height: 20))
            etiquetaFecha.text = "Fecha:"
            etiquetaFecha.font = .systemFont(ofSize: 17)
            etiquetaFecha.textColor = .black
            vista.addSubview(etiquetaFecha)

            // Valor de la fecha
            let valorFecha = UILabel(frame: CGRect(x: 80, y: 115, width: Int(vista.frame.width) - 90, height: 20))
            valorFecha.text = sensorTemperaturaAll[i].fech
            valorFecha.font = .systemFont(ofSize: 17)
            valorFecha.textColor = .black
            vista.addSubview(valorFecha)

            // Etiqueta "Hora:"
            let etiquetaHora = UILabel(frame: CGRect(x: 10, y: 140, width: 60, height: 20))
            etiquetaHora.text = "Hora:"
            etiquetaHora.font = .systemFont(ofSize: 17)
            etiquetaHora.textColor = .black
            vista.addSubview(etiquetaHora)

            // Valor de la hora
            let valorHora = UILabel(frame: CGRect(x: 80, y: 140, width: Int(vista.frame.width) - 90, height: 20))
            valorHora.text = sensorTemperaturaAll[i].hor
            valorHora.font = .systemFont(ofSize: 17)
            valorHora.textColor = .black
            vista.addSubview(valorHora)

            srcTemperaturaAll.addSubview(vista)
            y += 190
        }
        srcTemperaturaAll.contentSize = CGSize(width: 0, height: y)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
