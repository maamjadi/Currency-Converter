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
    @IBOutlet var currenciesTableView: UITableView!
    @IBOutlet weak var dimView: UIVisualEffectView!
    
    //if reverseArrowDirection is true, it will change to up
    private var reverseArrowDirection = false
    private var numberHasSet: Bool = false
    private var changetheCurrency: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currenciesTableView.delegate = self
        currenciesTableView.dataSource = self
        
        setupUI()
        
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(dimissCurrenciesTableView(_:)))
        dimView.addGestureRecognizer(tapToDismiss)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateArrow()
    }
    
    private func setupUI() {
        dimView.isHidden = true
        centerArrowBorder.layer.cornerRadius = centerArrowBorder.frame.width / 2
        centerArrowImageView.layer.cornerRadius = centerArrowImageView.frame.width / 2
    }
    
    @objc
    private func dimissCurrenciesTableView(_ sender: UITapGestureRecognizer?) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.isHidden = true
            self.currenciesTableView.transform = CGAffineTransform(scaleX: 0.01, y: 0.005)
        }, completion: {(success) in
            self.currenciesTableView.removeFromSuperview()
        })
    }
    
    @IBAction func firstCurrAction(_ sender: Any) {
        changetheCurrency = 0
        showCurrenciesTableView()
    }
    
    @IBAction func secondCurrAction(_ sender: Any) {
        changetheCurrency = 1
        showCurrenciesTableView()
    }
    
    private func showCurrenciesTableView() {
        currenciesTableView.center = self.view.center
        currenciesTableView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        currenciesTableView.layer.cornerRadius = 10
        self.view.addSubview(currenciesTableView)
        currenciesTableView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            self.dimView.isHidden = false
            self.currenciesTableView.transform = .identity
        })
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

extension ExchangeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        cell.textLabel?.text = "hi"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let theBtnCurrency = changetheCurrency, let theCurrency = currenciesTableView.cellForRow(at: indexPath)?.textLabel?.text else {
            return
        }
        if theBtnCurrency == 0 {
            firstCurrency.setTitle(theCurrency, for: .normal)
        }
        else if theBtnCurrency == 1 {
            secondCurrency.setTitle(theCurrency, for: .normal)
        } else {
            return
        }
        dimissCurrenciesTableView(nil)
    }
}
