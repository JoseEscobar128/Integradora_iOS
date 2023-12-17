//
//  LoginViewController.swift
//  Integradora
//
//  Created by Jose Escobar on 17/12/23.
//
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var txtEmail: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func btnAtras(_ sender: Any) {
        
        // regresar a la vista anterior
             self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnIngresar(_ sender: Any) {
        guard let url = URL(string: "http://3.129.244.114/api/login") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let userData = ["email": txtEmail.text,
                        "password": txtContrasena.text]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    self.mostrarAlerta(mensaje: "Error al realizar la solicitud: \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, let data = data {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                        switch httpResponse.statusCode {
                        case 200:
                            if let msg = jsonResponse?["msg"] as? String, msg.lowercased().contains("sesion iniciada") {
                                self.mostrarAlerta(mensaje: msg)
                            } else {
                                self.mostrarAlerta(mensaje: "Error en la respuesta del servidor (200).")
                            }
                        case 401:
                            if let msg = jsonResponse?["msg"] as? String, msg.lowercased().contains("no existe") {
                                self.mostrarAlerta(mensaje: msg)
                            } else {
                                self.mostrarAlerta(mensaje: "Error en la respuesta del servidor (401).")
                            }
                        case 422:
                            if let errorMsg = jsonResponse?["data"] as? [String: Any] {
                                var errorMessage = ""
                                for (key, value) in errorMsg {
                                    if let errors = value as? [String] {
                                        errorMessage += "\(key.capitalized): \(errors.joined(separator: ", "))\n"
                                    }
                                }
                                self.mostrarAlerta(mensaje: errorMessage)
                            } else {
                                self.mostrarAlerta(mensaje: "Error en la respuesta del servidor (422).")
                            }
                        case 404:
                            if let msg = jsonResponse?["msg"] as? String, msg.lowercased().contains("no existe") {
                                if let data = jsonResponse?["data"] as? String {
                                    self.mostrarAlerta(mensaje: "\(msg): \(data)")
                                } else {
                                    self.mostrarAlerta(mensaje: "Error en la respuesta del servidor (404).")
                                }
                            } else {
                                self.mostrarAlerta(mensaje: "Error en la respuesta del servidor (404).")
                            }
                        default:
                            self.mostrarAlerta(mensaje: "Error en la respuesta del servidor. Código de estado: \(httpResponse.statusCode)")
                        }
                    } catch {
                        self.mostrarAlerta(mensaje: "Error al analizar la respuesta JSON.")
                    }
                }
            }

            task.resume()

        } catch {
            self.mostrarAlerta(mensaje: "Error al convertir datos a JSON: \(error.localizedDescription)")
        }
    }

    // Función para mostrar una alerta en la vista
    func mostrarAlerta(mensaje: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Mensaje", message: mensaje, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
