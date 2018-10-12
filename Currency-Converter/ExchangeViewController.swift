//
//  ConverterViewController.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/11/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var firstCurrency: UIButton!
    @IBOutlet weak var firstAmount: UIButton!
    @IBOutlet weak var secondCurrency: UIButton!
    @IBOutlet weak var secondAmount: UIButton!
    @IBOutlet weak var centerArrowBorder: UIView!
    @IBOutlet weak var centerArrowImageView: UIImageView!
    
    //if reverseArrowDirection is true, it will change to up
    private var reverseArrowDirection = false
    private var numberHasSet: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateArrow()
    }
    
    private func setupUI() {
        centerArrowBorder.layer.cornerRadius = centerArrowBorder.frame.width / 2
        centerArrowImageView.layer.cornerRadius = centerArrowImageView.frame.width / 2
    }
    
    private func animateArrow() {
        if numberHasSet {
            var transformation = CGAffineTransform.identity
            if reverseArrowDirection {
                transformation = CGAffineTransform(rotationAngle: .pi)
            }
            
            UIView.animate(withDuration: 0.2) {
                self.centerArrowImageView.transform = transformation
            }
            numberHasSet = false
        }
    }
    
    @IBAction func firstCurrNumericVC(_ sender: UIButton) {
        reverseArrowDirection = false
        performSegue(withIdentifier: "numbericSegue", sender: sender)
    }
    
    @IBAction func secondCurrNumbericVC(_ sender: UIButton) {
        reverseArrowDirection = true
        performSegue(withIdentifier: "numbericSegue", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NumericViewController {
            controller.numberSetter = self
            guard let theButton = sender as? UIButton else {
                return
            }
            if theButton.titleLabel?.textColor == UIColor(named: "DarkColor") {
                controller.defaultColorTheme = true
            } else {
                controller.defaultColorTheme = false
            }
        }
    }
}

extension ExchangeViewController: NumberSetterProtocol {
    func set(num: String) {
        numberHasSet = true
        if !(reverseArrowDirection) {
            firstAmount.setTitle(num, for: .normal)
        } else {
            secondAmount.setTitle(num, for: .normal)
        }
    }
}
