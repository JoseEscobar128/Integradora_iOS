//
//  SensorView.swift
//  Integradora
//
//  Created by Jose Escobar on 13/12/23.
//

import UIKit

class SensorView<T>: UIView where T: SensorProtocol {

    private let imageView = UIImageView()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()
    private let lineView = UIView()
    private let dateLabel = UILabel()
    private let timeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        // Configuración de la vista del sensor
        backgroundColor = UIColor(red: CGFloat(0xFC) / 255.0, green: CGFloat(0xF5) / 255.0, blue: CGFloat(0xC7) / 255.0, alpha: 1.0)
        layer.cornerRadius = 10
        layer.masksToBounds = true

        // Configuración de la imagen del sensor
        imageView.frame = CGRect(x: 10, y: 10, width: 90, height: 90)
        addSubview(imageView)

        // Configuración del valor del sensor
        valueLabel.frame = CGRect(x: 110, y: 10, width: Int(frame.width) - 120, height: 60)
        valueLabel.font = .boldSystemFont(ofSize: 60)
        valueLabel.textAlignment = .center
        valueLabel.textColor = .black
        addSubview(valueLabel)

        // Configuración de las unidades del sensor
        unitLabel.frame = CGRect(x: 110, y: 70, width: Int(frame.width) - 120, height: 30)
        unitLabel.font = .systemFont(ofSize: 25)
        unitLabel.textAlignment = .center
        unitLabel.textColor = .black
        addSubview(unitLabel)

        // Configuración de la línea separadora
        lineView.frame = CGRect(x: 10, y: 110, width: Int(frame.width) - 20, height: 1)
        lineView.backgroundColor = .white
        addSubview(lineView)

        // Configuración de la etiqueta "Fecha:"
        dateLabel.frame = CGRect(x: 10, y: 115, width: 60, height: 20)
        dateLabel.font = .systemFont(ofSize: 17)
        dateLabel.textColor = .black
        addSubview(dateLabel)

        // Configuración del valor de la fecha
        let valueDateLabel = UILabel(frame: CGRect(x: 80, y: 115, width: Int(frame.width) - 90, height: 20))
        valueDateLabel.font = .systemFont(ofSize: 17)
        valueDateLabel.textColor = .black
        addSubview(valueDateLabel)

        // Configuración de la etiqueta "Hora:"
        timeLabel.frame = CGRect(x: 10, y: 140, width: 60, height: 20)
        timeLabel.font = .systemFont(ofSize: 17)
        timeLabel.textColor = .black
        addSubview(timeLabel)

        // Configuración del valor de la hora
        let valueTimeLabel = UILabel(frame: CGRect(x: 80, y: 140, width: Int(frame.width) - 90, height: 20))
        valueTimeLabel.font = .systemFont(ofSize: 17)
        valueTimeLabel.textColor = .black
        addSubview(valueTimeLabel)
    }

    func configure(with sensor: T) {
        // Configurar la vista del sensor con los datos proporcionados
        imageView.image = UIImage(named: sensor.imageName)
        valueLabel.text = String(sensor.value)
        unitLabel.text = sensor.unit
        dateLabel.text = "Fecha:"
        valueDateLabel.text = sensor.date
        timeLabel.text = "Hora:"
        valueTimeLabel.text = sensor.time
    }
}
