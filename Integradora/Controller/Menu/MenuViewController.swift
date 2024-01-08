//
//  MenuViewController.swift
//  Integradora
//
//  Created by Jose Escobar on 17/12/23.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var btnRegistrar: UIButton!
    @IBOutlet weak var btnCreditos: UIButton!
    
    @IBOutlet weak var btnIngresar: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func btnCreditos(_ sender: Any) {
        self.performSegue(withIdentifier: "sgCreditos", sender: nil)
    }
    @IBAction func btnRegistrar(_ sender: Any) {
        self.performSegue(withIdentifier: "sgRegistrar", sender: nil)
    }
    
    @IBAction func btnIngresar(_ sender: Any) {
        self.performSegue(withIdentifier: "sgIngresar", sender: nil)
    }
  

}
