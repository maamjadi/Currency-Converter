//
//  NumericViewController.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/12/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import UIKit

class NumericViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UITextField!
    @IBOutlet weak var numbersStackView: UIStackView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!
    
    var defaultColorTheme = true
    var numberSetter: NumberSetterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        numberLabel.text = "0"
    }
    
    override func viewWillLayoutSubviews() {
        setupUI()
    }
    
    private func setupUI() {
        var primaryColor = UIColor(named: "LightColor")
        var secondaryColor = UIColor(named: "DarkColor")
        if !(defaultColorTheme) {
            let tempCol = primaryColor
            primaryColor = secondaryColor
            secondaryColor = tempCol
        }
        
        self.view.backgroundColor = primaryColor
        numberLabel.textColor = secondaryColor
        
        //getting all the buttons in stackviews
        for stackView in numbersStackView.subviews {
            for view in stackView.subviews {
                if let btn = view as? UIButton {
                    if btn.currentTitle != "✓" {
                        btn.setTitleColor(secondaryColor, for: .normal)
                        btn.backgroundColor = secondaryColor?.withAlphaComponent(0.4)
                    }
                    btn.layer.cornerRadius = btn.frame.width / 2
                }
            }
        }
        doneBtn.setTitleColor(primaryColor, for: .normal)
        doneBtn.backgroundColor = secondaryColor
        dismissBtn.tintColor = secondaryColor
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func typeNumber(_ sender: UIButton) {
        guard let currentNum = numberLabel.text, let senderNum = sender.currentTitle else {
            return
        }
        var theString = currentNum + senderNum
        
        //the conditions to make sure about the correct format of the double numbers
        if (senderNum == "0") && (currentNum == "0") {
            return
        }
        else if (senderNum == ".") && (currentNum.contains(".")) {
            return
        }
        else if (senderNum != "0") && (senderNum != ".") && (currentNum == "0") {
            theString = senderNum
        }
        numberLabel.text = theString
    }
    
    @IBAction func doneAction(_ sender: Any) {
        if let numStr = numberLabel.text, numStr != "0" {
            numberSetter?.set(num: numStr)
        }
        dismiss(animated: true, completion: nil)
    }
}
