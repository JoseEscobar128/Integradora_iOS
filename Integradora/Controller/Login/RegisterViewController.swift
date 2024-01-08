//
//  RegisterViewController.swift
//  Integradora
//
//  Created by Jose Escobar on 17/12/23.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtContrasena: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtNombre: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        txtNombre.delegate = self
            txtEmail.delegate = self
            txtContrasena.delegate = self
    }
    
    @IBAction func btnAtras(_ sender: Any) {
        // regresar a la vista anterior
        self.dismiss(animated: true, completion: nil)
        
    }
    

    @IBAction func btnRegistro(_ sender: Any) {
        guard let url = URL(string: "http://18.117.124.234/api/register") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let usuarioData = ["name": txtNombre.text,
                           "email": txtEmail.text,
                           "password": txtContrasena.text]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: usuarioData, options: [])
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
                            if let msg = jsonResponse?["msg"] as? String, msg.lowercased().contains("ya existe") {
                                self.mostrarAlerta(mensaje: msg)
                            } else {
                                self.mostrarAlerta(mensaje: "Error en la respuesta del servidor (200).")
                            }
                        case 201:
                            
                                // Registro exitoso, regresar a la vista anterior
                                DispatchQueue.main.async {
                                    if let _ = self.storyboard?.instantiateViewController(withIdentifier: "SensoresViewController") {
                                        self.performSegue(withIdentifier: "sgSensores", sender: nil)
                                    }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtNombre:
            // Cuando se presiona "Return" en el campo de nombre, pasa al campo de correo electrónico
            txtEmail.becomeFirstResponder()
        case txtEmail:
            // Cuando se presiona "Return" en el campo de correo electrónico, pasa al campo de contraseña
            txtContrasena.becomeFirstResponder()
        case txtContrasena:
            // Cuando se presiona "Return" en el campo de contraseña, oculta el teclado
            textField.resignFirstResponder()
            // También puedes agregar aquí la lógica para realizar la acción de registro si es necesario
            // Llama a tu función btnRegistro(sender) o realiza la lógica que necesites aquí.
        default:
            break
        }
        
        return true
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
